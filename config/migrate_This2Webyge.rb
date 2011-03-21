#! /usr/bin/env ruby
# coding: UTF-8
#
# Script de migração da base de dados This para Weby.
#
require 'rubygems'
require 'pg'
require 'awesome_print'
require 'authlogic'
require 'yaml'
require 'cgi'
require 'htmlentities'
 
#authlogic = Authlogic::ActsAsAuthentic::Base::Config
class Migrate_this2weby
  def initialize(verbose=true)
    # Coneção com os dois bancos
    if not File.exist?("config-migrate.yml")
      puts "É necessário criar o arquivo config-migrate.yml com as diretivas de conexão."
      print "Exemplo:\nthis:\n  adapter: postgresql\n  host: localhost\n  database: this\n  username: this\n  password: senha_this\n\nweby:\n  adapter: postgresql\n  host: localhost\n  database: weby\n  username: weby\n  password: senha_weby\n"
      exit
    end
    @config = YAML::load(File.open("./config-migrate.yml"))
    @con_this = PGconn.connect(@config['this']['host'],nil,nil,nil,@config['this']['database'],@config['this']['username'],@config['this']['password'])
    @con_weby = PGconn.connect(@config['weby']['host'],nil,nil,nil,@config['weby']['database'],@config['weby']['username'],@config['weby']['password'])
    @verbose = verbose
    #@param = "WHERE site_id=17"
    @convar = {} # Variável de conversão
  end

  def migrate_this
    puts "Migrando tabela this.sites para weby.sites...\n" if @verbose
    select_sites = "SELECT * FROM sites #{@param} ORDER BY site_id"
    puts "\t#{select_sites}\n" if @verbose
    this_sites = @con_this.exec(select_sites)
    # Laço de repetição
    this_sites.each do |this_site|
      site_name = /http:\/\/www.([a-z]+).*\/([a-z]+)/.match("#{this_site['caminho_http']}")
      if not site_name.nil?
        site_name = "#{site_name[1]}_#{site_name[2]}"
      else
        site_name = /http:\/\/www.([a-z]+).*/.match("#{this_site['caminho_http']}")
        if not site_name.nil?
          site_name = site_name[1]
        end
      end
      site_name ||= this_site['site_id']

      select_rodape = "SELECT endereco,telefone FROM rodape WHERE site_id='#{this_site['site_id']}'"
      puts "\tRodapé: #{select_rodape}"
      rodape = @con_this.exec(select_rodape)
      rodape_text = "#{treat(rodape.first['endereco'])} #{rodape.first['telefone']}" unless rodape.first.nil?
      insert_site = "INSERT INTO sites (name,url,description,footer) VALUES ('#{site_name}','#{this_site['caminho_http']}','#{pre_treat(this_site['nm_site'])}','#{rodape_text}') RETURNING id"
      site = @con_weby.exec(insert_site)
      puts "\t\t(#{site[0]['id']}) #{insert_site}\n" if @verbose
      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"] = {}
      @convar["#{this_site['site_id']}"]["weby"] = site[0]['id']
      @convar["#{this_site['site_id']}"]["weby_name"] = "#{site_name}"

      puts "Migrando tabela this.usuarios para weby.users...\n" if @verbose
      select_usuarios = "SELECT * FROM usuarios #{@param} WHERE site_id='#{this_site['site_id']}' ORDER BY id"
      puts "\t#{select_usuarios}\n" if @verbose
      this_users = @con_this.exec(select_usuarios)
      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"]["usuarios"] = {}
      # Laço de repetição
      this_users.each do |this_user|
        # Separa o primeiro nome do resto
        first_name,last_name = this_user['nome'].split(" ",0)
        # Populando weby.users
        insert_usuario = "INSERT INTO users (register,first_name,last_name,login,crypted_password,email,phone,mobile,status,password_salt,persistence_token,single_access_token,perishable_token) VALUES ('#{this_user['matricula']}','#{pre_treat(first_name)}','#{pre_treat(last_name)}','#{this_user['login_name']}','#{this_user['senha']}','#{this_user['email']}','#{this_user['telefone']}','#{this_user['celular']}','#{this_user['status']}','#{Authlogic::Random.friendly_token}','#{Authlogic::Random.hex_token}','#{Authlogic::Random.friendly_token}','#{Authlogic::Random.friendly_token}') RETURNING id"
        puts "\t\t#{insert_usuario}\n" if @verbose
        user = @con_weby.exec(insert_usuario)
        # Relacionando usuários na variável de conversão
        @convar["#{this_site['site_id']}"]["usuarios"]["#{this_user['id']}"] = user[0]['id']
      end
      puts "Limpando tabela.\n" if @verbose
      this_users.clear()

      # Migrando Tabela: this.[noticias,eventos,informativos] => weby.pages
      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"]["noticias"] = {}
      select_noticias = "SELECT * FROM noticias WHERE site_id='#{this_site['site_id']}' ORDER BY id"
      puts "\t\t\t#{select_noticias}\n" if @verbose
      this_noticias = @con_this.exec(select_noticias)
      this_noticias.each do |noticia|
        capa = noticia['capa'] != false ? true : false
        dt_cadastro = ((noticia['dt_cadastro'].nil?) || (/([-]+)/.match("#{noticia['dt_cadastro']}").nil?)) ? Time.now : noticia['dt_cadastro']
        dt_inicio = ((noticia['dt_inicio'].nil?) || (/([-]+)/.match("#{noticia['dt_inicio']}").nil?)) ? Time.now : noticia['dt_inicio']
        dt_fim = ((noticia['dt_fim'].nil?) || (/([-]+)/.match("#{noticia['dt_fim']}").nil?)) ? 2.years.from_now : noticia['dt_fim']
        status = noticia['status'] == 'P' ? true : false
        autor = @convar["#{this_site['site_id']}"]['usuarios'][noticia['autor']]
        autor ||= 1
        insert_pages = "INSERT INTO pages (created_at,updated_at,date_begin_at,date_end_at,site_id,author_id,text,url,source,title,summary,publish,front,type) VALUES ('#{dt_cadastro}','#{dt_cadastro}','#{dt_inicio}','#{dt_fim}','#{site[0]['id']}','#{autor}','#{pre_treat(noticia['texto'])}','#{pre_treat(noticia['url'])}','#{pre_treat(noticia['fonte'])}','#{pre_treat(noticia['titulo'])}','#{pre_treat(noticia['resumo'])}',#{status},#{capa},'News') RETURNING id"
        page = @con_weby.exec(insert_pages)
        puts "\t\t\t\t(#{page[0]['id']}) #{insert_pages[0,300]}\n" if @verbose
        insert_sites_pages = "INSERT INTO sites_pages (site_id,page_id) VALUES ('#{site[0]['id']}','#{page[0]['id']}')"
        site_page = @con_weby.exec(insert_sites_pages)
        # Relacionando notícias na variável de conversão
        @convar["#{this_site['site_id']}"]["noticias"]["#{noticia['id']}"] = page[0]['id']
      end
      this_noticias.clear()

      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"]["paginas"] = {}
      select_paginas = "SELECT * FROM paginas WHERE site_id='#{this_site['site_id']}'"
      puts "\t\t\t#{select_paginas}\n" if @verbose
      this_paginas = @con_this.exec(select_paginas)
      this_paginas.each do |pagina|
        data_publica = ((pagina['dt_publica'].nil?) || (/([-]+)/.match("#{pagina['dt_publica']}").nil?)) ? 2.years.from_now : pagina['dt_publica']
        autor = @convar["#{this_site['site_id']}"]['usuarios'][pagina['autor']]
        autor ||= 1
        insert_pages = "INSERT INTO pages (created_at,date_begin_at,date_end_at,site_id,author_id,title,text,publish,front,type) VALUES ('#{Time.now}','#{Time.now}','#{data_publica}','#{site[0]['id']}','#{autor}','#{pre_treat(pagina['titulo'])}','#{pre_treat(pagina['texto'])}',true,false,'News') RETURNING id"
        page = @con_weby.exec(insert_pages)
        puts "\t\t\t\t(#{page[0]['id']}) #{insert_pages[0,300]}\n" if @verbose
        insert_sites_pages = "INSERT INTO sites_pages (site_id,page_id) VALUES ('#{site[0]['id']}','#{page[0]['id']}')"
        site_page = @con_weby.exec(insert_sites_pages)
        # Relacionando notícias na variável de conversão
        @convar["#{this_site['site_id']}"]["paginas"]["#{pagina['id']}"] = page[0]['id']
      end
      this_paginas.clear()

      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"]["eventos"] = {}
      select_eventos = "SELECT * FROM eventos WHERE site_id='#{this_site['site_id']}'"
      puts "\t\t\t#{select_eventos}\n" if @verbose
      this_eventos = @con_this.exec(select_eventos)
      # Conversão de tipo de evento
      kind_list = {"U" => "regional", "N" => "nacional", "I" => "internacional"}
      this_eventos.each do |evento|
        capa = evento['capa'] != false ? true : false
        tipo = evento['tipo'].nil? ? '' : kind_list["#{evento['tipo']}"]
        dt_cadastro = ((evento['dt_cadastro'].nil?) || (/([-]+)/.match("#{evento['dt_cadastro']}").nil?)) ? Time.now : evento['dt_cadastro']
        dt_inicio = ((evento['dt_inicio'].nil?) || (/([-]+)/.match("#{evento['dt_inicio']}").nil?)) ? Time.now : evento['dt_inicio']
        dt_fim = ((evento['dt_fim'].nil?) || (/([-]+)/.match("#{evento['dt_fim']}").nil?)) ? 2.years.from_now : evento['dt_fim']
        inicio = ((evento['inicio'].nil?) || (/([-]+)/.match("#{evento['inicio']}").nil?)) ? Time.now : evento['inicio']
        fim = ((evento['fim'].nil?) || (/([-]+)/.match("#{evento['fim']}").nil?)) ? Time.now : evento['fim']
        status = evento['status'] == 'P' ? true : false
        autor = @convar["#{this_site['site_id']}"]['usuarios'][evento['autor']]
        autor ||= 1
        insert_pages = "INSERT INTO pages (created_at,updated_at,date_begin_at,date_end_at,event_begin,event_end,site_id,author_id,text,url,source,title,summary,publish,front,type,kind,event_email,local) VALUES ('#{dt_cadastro}','#{dt_cadastro}','#{dt_inicio}','#{dt_fim}','#{inicio}','#{fim}','#{site[0]['id']}','#{autor}','#{pre_treat(evento['texto'])}','#{pre_treat(evento['url'])}','#{pre_treat(evento['fonte'])}','#{pre_treat(evento['titulo'])}','#{pre_treat(evento['resumo'])}',#{status},#{capa},'Event','#{tipo}','#{evento['email']}','#{pre_treat(evento['local_realiza'])}') RETURNING id"
        page = @con_weby.exec(insert_pages)
        puts "\t\t\t\t(#{page[0]['id']}) #{insert_pages[0,300]}\n" if @verbose
        insert_sites_pages = "INSERT INTO sites_pages (site_id,page_id) VALUES ('#{site[0]['id']}','#{page[0]['id']}')"
        site_page = @con_weby.exec(insert_sites_pages)
        # Relacionando notícias na variável de conversão
        @convar["#{this_site['site_id']}"]["eventos"]["#{evento['id']}"] = page[0]['id']
      end
      this_eventos.clear()

      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"]["informativos"] = {}
      select_informativos = "SELECT * FROM informativos WHERE site_id='#{this_site['site_id']}'"
      puts "\t\t\t#{select_informativos}\n" if @verbose
      this_informativos = @con_this.exec(select_informativos)
      # Conversão de tipo de evento
      this_informativos.each do |inform|
        dt_cadastro = ((inform['dt_cadastro'].nil?) || (/([-]+)/.match("#{inform['dt_cadastro']}").nil?)) ? Time.now : inform['dt_cadastro']
        dt_inicio = ((inform['dt_inicio'].nil?) || (/([-]+)/.match("#{inform['dt_inicio']}").nil?)) ? Time.now : inform['dt_inicio']
        dt_fim = ((inform['dt_fim'].nil?) || (/([-]+)/.match("#{inform['dt_fim']}").nil?)) ? 2.years.from_now : inform['dt_fim']
        autor = @convar["#{this_site['site_id']}"]['usuarios'][inform['autor']]
        autor ||= 1
        status = inform['status'] == 'P' ? true : false
        insert_banner = "INSERT INTO banners (created_at,updated_at,date_begin_at,date_end_at,site_id,user_id,text,url,title,publish,hide) VALUES ('#{dt_cadastro}','#{dt_cadastro}','#{dt_inicio}','#{dt_fim}','#{site[0]['id']}','#{autor}','#{pre_treat(inform['texto'])}','#{pre_treat(inform['url'])}','#{pre_treat(inform['assunto'])}',#{status},false) RETURNING id"
        banner = @con_weby.exec(insert_banner)
        puts "\t\t\t\t(#{banner[0]['id']}) #{insert_banner[0,300]}\n" if @verbose
        # Relacionando notícias na variável de conversão
        @convar["#{this_site['site_id']}"]["informativos"]["#{inform['id']}"] = banner[0]['id']
      end
      this_informativos.clear()

      # Migrando Tabelas: this.menu_[direito,esquerdo,superior,inferior] => weby.menus 
      # Parâmetros: 
      #   1o. menus   (Hash)    Onde os índices são as tabelas no this e os valores são seus respectivos no weby
      #   2o. this_id (integer) id do site no this
      #   3o. weby_id (integer) id do site no weby
      migrate_this_menus({'direito' => 'auxiliary', 'esquerdo' => 'secondary', 'superior' => 'main', 'inferior' => 'base'}, this_site['site_id'], site[0]['id'])

    end
    this_sites.clear()

    # Tratando links de weby.pages
    select_pages = "SELECT id,title,url,source,summary,text FROM pages"
    puts "\t\t\t#{select_pages}\n" if @verbose
    weby_pages = @con_weby.exec(select_pages)
    weby_pages.each do |weby_page|
      update_page = "UPDATE pages SET title='#{treat(weby_page['title'])}',url='#{treat(weby_page['url'])}',source='#{treat(weby_page['source'])}',summary='#{treat(weby_page['summary'])}',text='#{treat(weby_page['text'])}' WHERE id='#{weby_page['id']}'"
      puts "\t\t\t\t(#{weby_page['id']}) #{update_page[0,300]}\n" if @verbose
      page = @con_weby.exec(update_page)
    end
    weby_pages.clear()

  end

  # Metodo para chamada recursiva
  def deep_insert_menu(sons, entry, this_id, site_id, menu_id, type)
    if not entry['texto'].nil? # Se o campo texto for significante o menu está embutido
      modificador = @convar["#{this_id}"]['usuarios'][entry['modificador']] 
      modificador ||= 1
      insert_page = "INSERT INTO pages (created_at,date_begin_at,date_end_at,site_id,author_id,title,text,publish,front,type) VALUES ('#{Time.now}','#{Time.now}','#{Time.now}','#{site_id}','#{modificador}','#{pre_treat(entry['texto_item'])}','#{pre_treat(entry['texto'])}',true,false,'News') RETURNING id"
      page_id = @con_weby.exec(insert_page)
      puts "\t\t\t\t\t(#{page_id[0]['id']}) #{insert_page[0,300]}" if @verbose
      insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{pre_treat(entry['texto_item'])}','','#{page_id[0]['id']}') RETURNING id"
    elsif not /javascript:mostrar_pagina.*\('([0-9]+)'.*/.match("#{entry['url']}").nil? # Verificando se o menu é interno, externo
      page_id = /javascript:mostrar_pagina.*\('([0-9]+)'.*/.match("#{entry['url']}")[1]
      page_id = @convar["#{this_id}"]["paginas"]["#{page_id}"]
      insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{pre_treat(entry['texto_item'])}','','#{page_id}') RETURNING id"
    else
      insert_menu = "INSERT INTO menus (title,link) VALUES ('#{pre_treat(entry['texto_item'])}','#{pre_treat(entry['url'])}') RETURNING id"
    end
    menu_sub = @con_weby.exec(insert_menu)
    puts "\t\t\t\t(#{menu_sub[0]['id']}) #{insert_menu}\n" if @verbose
    insert_sites_menus = "INSERT INTO sites_menus(site_id,menu_id,parent_id,side) VALUES ('#{site_id}','#{menu_sub[0]['id']}',#{menu_id},'#{type}') RETURNING id"
    menu_e0 = @con_weby.exec(insert_sites_menus)
    puts "\t\t\t\t(#{menu_e0[0]['id']}) #{insert_sites_menus}\n" if @verbose

    if sons["#{entry['id']}"].class.to_s == "Array"
      sons["#{entry['id']}"].each do |child|
        deep_insert_menu(sons, child, this_id, site_id, menu_e0[0]['id'], type)
      end
    end
  end
  # Método para migração dos menus
  def migrate_this_menus(menus, this_id, weby_id)
    menus.each do |menus_this|
      select_menu = "SELECT * FROM menu_#{menus_this[0]} WHERE site_id='#{this_id}'"
      puts "\t\t\t#{select_menu}\n" if @verbose
      menu_this = @con_this.exec(select_menu)
      # Agrupando por item_pai
      menus_this_groupby = menu_this.group_by{|i| i['item_pai']}
      # Laço
      unless menus_this_groupby["0"].nil?
        menus_this_groupby["0"].each do |menu|
          # Recursão
          deep_insert_menu(menus_this_groupby, menu, this_id, weby_id, '0', menus_this[1])
        end
        menus_this_groupby.clear()
      end
      menu_this.clear()
    end
  end
  # Pré tratamento de caracteres
  def pre_treat(string)
    unless string.nil?
      coder = HTMLEntities.new
      string = coder.decode(string)
      string = @con_weby.escape(string)
    end
    return string
  end
  # Tratamento de caracteres 
  def treat(string)
    unless string.nil?
      if string.match(/javascript:mostrar_pagina\('([0-9]+)','([0-9]+)'\);/)
        string.gsub!(/javascript:mostrar_pagina\('([0-9]+)','([0-9]+)'\);/){|x| "/sites/#{@convar[$2]['weby_name']}/pages/#{@convar[$2]["paginas"][$1]}" }
      end
      if string.match(/javascript:mostrar_noticia\('([0-9]+)','([0-9]+)'\);/)
        string.gsub!(/javascript:mostrar_noticia\('([0-9]+)','([0-9]+)'\);/){|x| "/sites/#{@convar[$2]['weby_name']}/pages/#{@convar[$2]["noticias"][$1]}" }
      end
      string = @con_weby.escape(string)
    end
    return string
  end
  # Destrutor
  def finalize
    @con_this.close()
    @con_weby.close()
    File.open('convar.yaml', 'w') do |out|
       YAML::dump(@convar, out)
    end
  end
end

this2weby = Migrate_this2weby.new
this2weby.migrate_this
this2weby.finalize
