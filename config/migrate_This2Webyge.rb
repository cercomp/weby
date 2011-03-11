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
    @param = "WHERE site_id=17"
    @convar = {} # Variável de conversão
  end

  def migrate_this
    puts "Migrando tabela this.sites para weby.sites...\n" if @verbose
    select_sites = "SELECT * FROM sites #{@param}"
    puts "\t#{select_sites}\n" if @verbose
    sites_this = @con_this.exec(select_sites)
    # Laço de repetição
    sites_this.each do |s_this|
      site_name = /http:\/\/www.([a-z]+).*\/([a-z]+)/.match("#{s_this['caminho_http']}").nil? ? /http:\/\/www.([a-z]+).*/.match("#{s_this['caminho_http']}")[1] : /http:\/\/www.([a-z]+).*\/([a-z]+)/.match("#{s_this['caminho_http']}")[2]
      select_rodape = "SELECT * FROM rodape WHERE site_id='#{s_this['site_id']}'"
      rodape = @con_this.exec(select_rodape)
      insert_site = "INSERT INTO sites (name,url,description,footer) VALUES ('#{site_name}','#{s_this['caminho_http']}','#{treatment(s_this['nm_site'])}','#{rodape[0]['endereco']} #{rodape[0]['telefone']}') RETURNING id"
      site = @con_weby.exec(insert_site)
      puts "\t\t(#{site[0]['id']}) #{insert_site}\n" if @verbose
      # Criando objeto de conversão
      @convar["#{s_this['site_id']}"] = {}
      @convar["#{s_this['site_id']}"]["weby"] = site[0]['id']

      puts "Migrando tabela this.usuarios para weby.users...\n" if @verbose
      select_usuarios = "SELECT * FROM usuarios #{@param}"
      puts "\t#{select_usuarios}\n" if @verbose
      users_this = @con_this.exec(select_usuarios)
      # Criando objeto de conversão
      @convar["#{s_this['site_id']}"]["usuarios"] = {}
      # Laço de repetição
      users_this.each do |u_this|
        # Separa o primeiro nome do resto
        first_name,last_name = u_this['nome'].split(" ",0)
        # Populando weby.users
        insert_usuario = "INSERT INTO users (register,first_name,last_name,login,crypted_password,email,phone,mobile,status,password_salt,persistence_token,single_access_token,perishable_token) VALUES ('#{u_this['matricula']}','#{first_name}','#{last_name}','#{u_this['login_name']}','#{u_this['senha']}','#{u_this['email']}','#{u_this['telefone']}','#{u_this['celular']}','#{u_this['status']}','#{Authlogic::Random.friendly_token}','#{Authlogic::Random.hex_token}','#{Authlogic::Random.friendly_token}','#{Authlogic::Random.friendly_token}') RETURNING id"
        puts "\t\t#{insert_usuario}\n" if @verbose
        user = @con_weby.exec(insert_usuario)
        # Relacionando usuários na variável de conversão
        @convar["#{s_this['site_id']}"]["usuarios"]["#{u_this['id']}"] = user[0]['id']
      end
      puts "Limpando tabela.\n" if @verbose
      users_this.clear()

      # Migrando Tabela: this.[noticias,eventos,informativos] => weby.pages
      # Criando objeto de conversão
      @convar["#{s_this['site_id']}"]["noticias"] = {}
      select_noticias = "SELECT * FROM noticias WHERE site_id='#{s_this['site_id']}'"
      puts "\t\t\t#{select_noticias}\n" if @verbose
      this_noticias = @con_this.exec(select_noticias)
      this_noticias.each do |t_n|
        capa = t_n['capa'] != false ? true : false
        dt_fim = t_n['dt_fim'].nil? ? 2.years.from_now : t_n['dt_fim']
        status = t_n['status'] == 'P' ? true : false
        insert_pages = "INSERT INTO pages (created_at,updated_at,date_begin_at,date_end_at,site_id,author_id,text,url,source,title,summary,publish,front,type) VALUES ('#{t_n['dt_cadastro']}','#{t_n['dt_cadastro']}','#{t_n['dt_inicio']}','#{dt_fim}','#{site[0]['id']}','#{@convar["#{s_this['site_id']}"]['usuarios'][t_n['autor']]}','#{treatment(t_n['texto'])}','#{treatment(t_n['url'])}','#{treatment(t_n['fonte'])}','#{treatment(t_n['titulo'])}','#{treatment(t_n['resumo'])}',#{status},#{capa},'News') RETURNING id"
        page = @con_weby.exec(insert_pages)
        puts "\t\t\t\t(#{page[0]['id']}) #{insert_pages[0,300]}\n" if @verbose
        insert_sites_pages = "INSERT INTO sites_pages (site_id,page_id) VALUES ('#{site[0]['id']}','#{page[0]['id']}')"
        site_page = @con_weby.exec(insert_sites_pages)
        # Relacionando notícias na variável de conversão
        @convar["#{s_this['site_id']}"]["noticias"]["#{t_n['id']}"] = page[0]['id']
      end
      this_noticias.clear()

      # Criando objeto de conversão
      @convar["#{s_this['site_id']}"]["paginas"] = {}
      select_paginas = "SELECT * FROM paginas WHERE site_id='#{s_this['site_id']}'"
      puts "\t\t\t#{select_paginas}\n" if @verbose
      this_paginas = @con_this.exec(select_paginas)
      this_paginas.each do |t_n|
        data_publica = ((t_n['dt_publica'].nil?) || (/([-]+)/.match("#{t_n['dt_publica']}").nil?)) ? 2.years.from_now : t_n['dt_publica']
        insert_pages = "INSERT INTO pages (created_at,date_begin_at,date_end_at,site_id,author_id,title,text,publish,front,type) VALUES ('#{Time.now}','#{Time.now}','#{data_publica}','#{site[0]['id']}','#{@convar["#{s_this['site_id']}"]['usuarios'][t_n['autor']]}','#{treatment(t_n['titulo'])}','#{treatment(t_n['texto'])}',true,false,'News') RETURNING id"
        page = @con_weby.exec(insert_pages)
        puts "\t\t\t\t(#{page[0]['id']}) #{insert_pages[0,300]}\n" if @verbose
        insert_sites_pages = "INSERT INTO sites_pages (site_id,page_id) VALUES ('#{site[0]['id']}','#{page[0]['id']}')"
        site_page = @con_weby.exec(insert_sites_pages)
        # Relacionando notícias na variável de conversão
        @convar["#{s_this['site_id']}"]["paginas"]["#{t_n['id']}"] = page[0]['id']
      end
      this_paginas.clear()

      # Criando objeto de conversão
      @convar["#{s_this['site_id']}"]["eventos"] = {}
      select_eventos = "SELECT * FROM eventos WHERE site_id='#{s_this['site_id']}'"
      puts "\t\t\t#{select_eventos}\n" if @verbose
      this_eventos = @con_this.exec(select_eventos)
      # Conversão de tipo de evento
      kind_list = {"U" => "regional", "N" => "nacional", "I" => "internacional"}
      this_eventos.each do |t_n|
        capa = t_n['capa'] != false ? true : false
        tipo = t_n['tipo'].nil? ? '' : kind_list["#{t_n['tipo']}"]
        dt_fim = t_n['dt_fim'].nil? ? 2.years.from_now : t_n['dt_fim']
        status = t_n['status'] == 'P' ? true : false
        insert_pages = "INSERT INTO pages (created_at,updated_at,date_begin_at,date_end_at,event_begin,event_end,site_id,author_id,text,url,source,title,summary,publish,front,type,kind,event_email,local) VALUES ('#{t_n['dt_cadastro']}','#{t_n['dt_cadastro']}','#{t_n['dt_inicio']}','#{dt_fim}','#{t_n['inicio']}','#{t_n['fim']}','#{site[0]['id']}','#{@convar["#{s_this['site_id']}"]['usuarios'][t_n['autor']]}','#{treatment(t_n['texto'])}','#{treatment(t_n['url'])}','#{treatment(t_n['fonte'])}','#{treatment(t_n['titulo'])}','#{treatment(t_n['resumo'])}',#{status},#{capa},'Event','#{tipo}','#{t_n['email']}','#{t_n['local_realiza']}') RETURNING id"
        page = @con_weby.exec(insert_pages)
        puts "\t\t\t\t(#{page[0]['id']}) #{insert_pages[0,300]}\n" if @verbose
        insert_sites_pages = "INSERT INTO sites_pages (site_id,page_id) VALUES ('#{site[0]['id']}','#{page[0]['id']}')"
        site_page = @con_weby.exec(insert_sites_pages)
        # Relacionando notícias na variável de conversão
        @convar["#{s_this['site_id']}"]["eventos"]["#{t_n['id']}"] = page[0]['id']
      end
      this_eventos.clear()

      # Criando objeto de conversão
      @convar["#{s_this['site_id']}"]["informativos"] = {}
      select_informativos = "SELECT * FROM informativos WHERE site_id='#{s_this['site_id']}'"
      puts "\t\t\t#{select_informativos}\n" if @verbose
      this_informativos = @con_this.exec(select_informativos)
      # Conversão de tipo de evento
      this_informativos.each do |t_n|
        dt_fim = t_n['dt_fim'].nil? ? 2.years.from_now : t_n['dt_fim']
        status = t_n['status'] == 'P' ? true : false
        insert_banner = "INSERT INTO banners (created_at,updated_at,date_begin_at,date_end_at,site_id,user_id,text,url,title,publish,hide) VALUES ('#{t_n['dt_cadastro']}','#{t_n['dt_cadastro']}','#{t_n['dt_inicio']}','#{dt_fim}','#{site[0]['id']}','#{@convar["#{s_this['site_id']}"]['usuarios'][t_n['autor']]}','#{treatment(t_n['texto'])}','#{treatment(t_n['url'])}','#{treatment(t_n['assunto'])}',#{status},false) RETURNING id"
        banner = @con_weby.exec(insert_banner)
        puts "\t\t\t\t(#{banner[0]['id']}) #{insert_banner[0,300]}\n" if @verbose
        # Relacionando notícias na variável de conversão
        @convar["#{s_this['site_id']}"]["informativos"]["#{t_n['id']}"] = banner[0]['id']
      end
      this_informativos.clear()

      # Migrando Tabelas: this.menu_[direito,esquerdo,superior,inferior] => weby.menus 
      # Parâmetros: 
      #   1o. menus   (Hash)    Onde os índices são as tabelas no this e os valores são seus respectivos no weby
      #   2o. this_id (integer) id do site no this
      #   3o. weby_id (integer) id do site no weby
      migrate_this_menus({'direito' => 'auxiliary', 'esquerdo' => 'secondary', 'superior' => 'main', 'inferior' => 'base'}, s_this['site_id'], site[0]['id'])

    end
    sites_this.clear()
  end

  # Metodo para chamada recursiva
  def deep_insert_menu(sons, entry, this_id, site_id, menu_id, type)
    if not entry['texto'].empty? # Se o campo texto for significante o menu está embutido
      insert_page = "INSERT INTO pages (created_at,date_begin_at,date_end_at,site_id,author_id,title,text,publish,front,type) VALUES ('#{Time.now}','#{Time.now}','#{Time.now}','#{site_id}','#{@convar["#{this_id}"]['usuarios'][entry['modificador']]}','#{treatment(entry['texto_item'])}','#{treatment(entry['texto'])}',true,false,'News') RETURNING id"
      page_id = @con_weby.exec(insert_page)
      puts "\t\t\t\t\t(#{page_id[0]['id']}) #{insert_page[0,300]}" if @verbose
      insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{treatment(entry['texto_item'])}','','#{page_id[0]['id']}') RETURNING id"
    elsif not /javascript:mostrar_pagina.*\('([0-9]+)'.*/.match("#{entry['url']}").nil? # Verificando se o menu é interno, externo
      page_id = /javascript:mostrar_pagina.*\('([0-9]+)'.*/.match("#{entry['url']}")[1]
      page_id = @convar["#{this_id}"]["paginas"]["#{page_id}"]
      insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{treatment(entry['texto_item'])}','','#{page_id}') RETURNING id"
    else
      insert_menu = "INSERT INTO menus (title,link) VALUES ('#{treatment(entry['texto_item'])}','#{treatment(entry['url'])}') RETURNING id"
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

  def treatment(string)
    coder = HTMLEntities.new
    string = coder.decode(string)
    string = @con_weby.escape(string)
    return string
  end

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
