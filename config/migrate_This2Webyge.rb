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
require 'iconv'
 
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
      puts "\tRodapé: #{pre_treat(select_rodape)}"
      rodape = @con_this.exec(select_rodape)
      rodape_text = "#{pre_treat(rodape.first['endereco'])} #{pre_treat(rodape.first['telefone'])}" unless rodape.first.nil?
#      rodape_text = rodape_text.force_encoding("UTF-8").valid_encoding? ? rodape_text : "" if rodape_text
      insert_site = "INSERT INTO sites (name,url,description,footer) VALUES ('#{pre_treat(site_name)}','#{pre_treat(this_site['caminho_http'])}','#{pre_treat(this_site['nm_site'])}','#{rodape_text}') RETURNING id"
      site = @con_weby.exec(insert_site)
      puts "\t\t(#{site[0]['id']}) #{insert_site}\n" if @verbose
      # Criando objeto de conversão
      @convar["#{this_site['site_id']}"] = {}
      @convar["#{this_site['site_id']}"]["weby"] = site[0]['id']
      @convar["#{this_site['site_id']}"]["weby_name"] = "#{site_name}"
      
      # Migrando estilos
      puts "Migrando tabela this.estilo"
      select_estilo = "SELECT * FROM estilo WHERE id='#{this_site['id_estilo']}'"
      puts "\t\t#{select_estilo}\n" if @verbose
      this_estilo = @con_this.exec(select_estilo)

      unless this_estilo.first.nil?
      weby_estilo = <<EOF
/* Principal */
/* Fundo do site */
  html{ background: #{this_estilo.first['body_background']}; }
/* Borda dos menus */ 
  aside menu li,
  header nav menu li,
  footer nav menu li { border:1px solid #{this_estilo.first['body_background']}; }
/* Fundo Tabela frontal das páginas */ 
  #no_front_news table,
  #no_front_news table th,
  #no_front_news table td { border-color: #{this_estilo.first['cor_borda_noticias']}; }
  #no_front_news table th { background-color: #{this_estilo.first['cor_borda_noticias']}; }
/* Cor titulo da tabela frontal das páginas */
  #no_front_news table th { color: #{this_estilo.first['cor_letra_topo_noticias']}; }
/* Cor Letra Titulo Tabela Frontal */ 
  #no_front_news table td a { color: #{this_estilo.first['cor_letra_link_noticias_out']}; }
/* Cor Letra Titulo Tabela Frontal Hover */ 
  #no_front_news table td a:hover { color: #{this_estilo.first['cor_letra_link_noticias_over']}; }
/* Cor Letra Tabela Frontal */ 
  #no_front_news table td { color: #{this_estilo.first['cor_letra_noticias_resumos']}; }
/* Cor da letra do rodape */ 
  footer section#info { color: #{this_estilo.first['cor_letra_rodape']}; }
/* Menu  */
  /* Esquerdo  */
    /* Menu  */
      /* Cor */ 
        aside.left menu li a { background-color: #{this_estilo.first['cor_mouseout']} !important; }
      /* Cor Hover */ 
        aside.left menu li:hover { background-color: #{this_estilo.first['cor_mouseover']}; }
      /* Cor fonte */ 
        aside.left menu li a { color: #{this_estilo.first['cor_letra_out']} !important; }
      /* Cor fonte hover */ 
        aside.left menu li a:hover { color: #{this_estilo.first['cor_letra_hover']} !important; }
    /* Submenu  */
      /* Cor */ 
        aside.left menu li.sub > a { background-color: #{this_estilo.first['cor_td_subitem_mouseout']} !important; }
      /* Cor Hover */ 
        aside.left menu li.sub:hover { background-color: #{this_estilo.first['cor_td_subitem_mouseover']} !important; }
      /* Cor fonte */ 
        aside.left menu li.sub > a { color: #{this_estilo.first['cor_letra_subitem_out']} !important; }
      /* Cor fonte hover */ 
        aside.left menu li.sub > a:hover { color: #{this_estilo.first['cor_letra_subitem_over']} !important; }
    /* Menu  */
      /* Cor */
        aside.right menu li a { background-color: #{this_estilo.first['cor_mouseout2']} !important; }
      /* Cor Hover */
        aside.right menu li:hover { background-color: #{this_estilo.first['cor_mouseover2']}; }
      /* Cor fonte */
        aside.right menu li a { color: #{this_estilo.first['cor_letra_out2']} !important; }
      /* Cor fonte hover */
        aside.right menu li a:hover { color: #{this_estilo.first['cor_letra_hover2']} !important; }
    /* Submenu  */
      /* Cor */
        aside.right menu li.sub > a { background-color: #{this_estilo.first['cor_td_subitem_mouseout2']} !important; }
      /* Cor Hover */
        aside.right menu li.sub:hover { background-color: #{this_estilo.first['cor_td_subitem_mouseover2']} !important; }
      /* Cor fonte */
        aside.right menu li.sub > a { color: #{this_estilo.first['cor_letra_subitem_out2']} !important; }
      /* Cor fonte hover */
        aside.right menu li.sub > a:hover { color: #{this_estilo.first['cor_letra_subitem_over2']} !important; }
  /* Superior  */
    /* Menu  */
      /* Cor */
        header nav menu li a { background-color: #{this_estilo.first['cor_mouseout3']} !important; }
      /* Cor Hover */
        header nav menu li:hover { background-color: #{this_estilo.first['cor_mouseover3']}; }
      /* Cor fonte */
        header nav menu li a { color: #{this_estilo.first['cor_letra_out3']} !important; }
      /* Cor fonte hover */
        header nav menu li a:hover { color: #{this_estilo.first['cor_letra_hover3']} !important; }
  /* Inferior  */
    /* Menu  */
      /* Cor */
        footer nav menu li a { background-color: #{this_estilo.first['cor_mouseout4']} !important; }
      /* Cor Hover */
        footer nav menu li:hover { background-color: #{this_estilo.first['cor_mouseover4']}; }
      /* Cor fonte */
        footer nav menu li a { color: #{this_estilo.first['cor_letra_out4']} !important; }
      /* Cor fonte hover */
        footer nav menu li a:hover { color: #{this_estilo.first['cor_letra_hover4']} !important; }
/* CSS  */
/* Estilo das páginas  */
  /* Cor Links */
    section#content article > p a { color: #{this_estilo.first['cor_letra_links_out']} !important; }
  /* Cor Links Hover */
    section#content article > p a:hover { color: #{this_estilo.first['cor_letra_links_over']} !important; }
  /* Cor Letra */
    section#content article > p,
    section#content article > summary { color: #{this_estilo.first['cor_letra_paragrafos']} !important; }}
  /* Cor Titulos */
    section#content article header h1,
    section#content article header h2 {color: #{this_estilo.first['cor_letra_subtitulos']} !important; }}
  /* Cor Subtitulos */
    section#content article header,
    section#content article header summary { color: #{this_estilo.first['cor_letra_titulos']} !important; }}
  /* Avançado */
    /* Pegar todo o CSS avançado, guardar em um arquivo */
    /* #{this_estilo.first['avancado']} */
EOF
      end
      insert_css = "INSERT INTO csses (name,css) VALUES ('#{site_name}','#{pre_treat(weby_estilo)}') RETURNING id"
      css = @con_weby.exec(insert_css)
      puts "\t\t\t(#{css[0]['id']}) #{insert_css[0,300]}\n" if @verbose
      insert_sites_csses = "INSERT INTO sites_csses (site_id,css_id,publish,owner) VALUES ('#{site[0]['id']}','#{css[0]['id']}',true,true)"
      site_css = @con_weby.exec(insert_sites_csses)

      puts "Migrando tabela this.usuarios para weby.users...\n" if @verbose
        param_aux = "#{@param} AND " if @param
        param_aux = "WHERE" if not @param
        select_usuarios = "SELECT * FROM usuarios #{param_aux} site_id='#{this_site['site_id']}' ORDER BY id"
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
          insert_banner = "INSERT INTO banners (created_at,updated_at,date_begin_at,date_end_at,site_id,user_id,text,url,title,publish,hide,width) VALUES ('#{dt_cadastro}','#{dt_cadastro}','#{dt_inicio}','#{dt_fim}','#{site[0]['id']}','#{autor}','#{pre_treat(inform['texto'])}','#{pre_treat(inform['url'])}','#{pre_treat(inform['assunto'])}',#{status},false,'153') RETURNING id"
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
        @convar["#{this_site['site_id']}"]["menus"] ||= {}
        migrate_this_menus({'direito' => 'auxiliary', 'esquerdo' => 'secondary', 'superior' => 'main', 'inferior' => 'base'}, this_site['site_id'], site[0]['id'])

      end
      this_sites.clear()

      # Tratando links de weby.menus
      select_menus = "SELECT id,title,link FROM menus"
      puts "\t\t\t#{select_menus}\n" if @verbose
      weby_menus = @con_weby.exec(select_menus)
      weby_menus.each do |weby_menu|
        update_menu = "UPDATE menus SET title='#{treat(weby_menu['title'])}',link='#{treat(weby_menu['link'])}' WHERE id='#{weby_menu['id']}'"
        puts "\t\t\t\t(#{weby_menu['id']}) #{update_menu[0,300]}\n" if @verbose
        @con_weby.exec(update_menu)
      end
      weby_menus.clear()

      # Tratando links de weby.pages
      select_pages = "SELECT id,title,url,source,summary,text FROM pages"
      puts "\t\t\t#{select_pages}\n" if @verbose
      weby_pages = @con_weby.exec(select_pages)
      weby_pages.each do |weby_page|
        update_page = "UPDATE pages SET title='#{treat(weby_page['title'])}',url='#{treat(weby_page['url'])}',source='#{treat(weby_page['source'])}',summary='#{treat(weby_page['summary'])}',text='#{treat(weby_page['text'])}' WHERE id='#{weby_page['id']}'"
        puts "\t\t\t\t(#{weby_page['id']}) #{update_page[0,300]}\n" if @verbose
        @con_weby.exec(update_page)
      end
      weby_pages.clear()
    end

    # Metodo para chamada recursiva
    def deep_insert_menu(sons, entry, this_id, site_id, menu_id, type)
      if (not entry['texto'].nil?) and (entry['texto'].size > 5) # Se o campo texto não for nulo e não for vazio então o menu está embutido
        modificador = @convar["#{this_id}"]['usuarios'][entry['modificador']] 
        modificador ||= 1
        insert_page = "INSERT INTO pages (created_at,date_begin_at,date_end_at,site_id,author_id,title,text,publish,front,type) VALUES ('#{Time.now}','#{Time.now}','#{Time.now}','#{site_id}','#{modificador}','#{pre_treat(entry['texto_item'])}','#{pre_treat(entry['texto'])}',true,false,'News') RETURNING id"
        page_id = @con_weby.exec(insert_page)
        @convar["#{this_id}"]["paginas"]["#{entry['id']}"] = page_id[0]['id']
        puts "\t\t\t\t\t(#{page_id[0]['id']}) #{insert_page[0,300]}" if @verbose
        insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{pre_treat(entry['texto_item'])}','','#{page_id[0]['id']}') RETURNING id"
      elsif not /javascript:mostrar_pagina.*\('([0-9]+)'.*/.match("#{entry['url']}").nil? # Verificando se o menu é interno, externo
        page_id = /javascript:mostrar_pagina.*\('([0-9]+)'.*/.match("#{entry['url']}")[1]
        page_id = @convar["#{this_id}"]["paginas"]["#{page_id}"]
        insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{pre_treat(entry['texto_item'])}','','#{page_id}') RETURNING id" unless page_id.nil?

      elsif not /javascript:mostrar_menu.*\('([0-9]+)'.*/.match("#{entry['url']}").nil?
        page_id = /javascript:mostrar_menu.*\('([0-9]+)'.*/.match("#{entry['url']}")[1]
        page_id = @convar["#{this_id}"]["paginas"]["#{page_id}"]
        insert_menu = "INSERT INTO menus (title,link,page_id) VALUES ('#{pre_treat(entry['texto_item'])}','','#{page_id}') RETURNING id" unless page_id.nil?

      else
        insert_menu = "INSERT INTO menus (title,link) VALUES ('#{pre_treat(entry['texto_item'])}','#{pre_treat(entry['url'])}') RETURNING id"
      end
      # Evitar erros quando não consegue inserir menu
      unless insert_menu.nil?
        menu_sub = @con_weby.exec(insert_menu)
        puts "\t\t\t\t(#{menu_sub[0]['id']}) #{insert_menu}\n" if @verbose
        insert_sites_menus = "INSERT INTO sites_menus(site_id,menu_id,parent_id,side,position) VALUES ('#{site_id}','#{menu_sub[0]['id']}',#{menu_id},'#{type}','#{entry['posicao']}') RETURNING id"
        menu_e0 = @con_weby.exec(insert_sites_menus)
        puts "\t\t\t\t(#{menu_e0[0]['id']}) #{insert_sites_menus}\n" if @verbose
      else
        menu_e0 = []
        menu_e0 << {'id' => menu_id}
      end

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
        if menus_this[0] != 'inferior'
          # Agrupando por item_pai
          menus_this_groupby = menu_this.group_by{|i| i['item_pai']}
        else
          menus_this_groupby = {}
          menus_this_groupby["0"] = menu_this.each{|i| i}
        end
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
				str = Iconv.conv("UTF-8//IGNORE","ASCII","#{string}")
        str = @con_weby.escape(str)
        str = coder.decode(str)
      end
      return str
    end
    # Tratamento de caracteres 
    def treat(string)
      unless string.nil?
        str = @con_weby.escape(string)
        if str.match(/javascript:mostrar_pagina.*'([0-9]+)'.*'([0-9]+)'.*/) 
          str.gsub!(/javascript:mostrar_pagina.*'([0-9]+)'.*'([0-9]+)'.*;/){|x| "/sites/#{@convar[$2]['weby_name']}/pages/#{@convar[$2]["paginas"][$1]}" if @convar[$2] }
        end 
        if str.match(/javascript:mostrar_noticia.*'([0-9]+)'.*'([0-9]+)'.*/)
          str.gsub!(/javascript:mostrar_noticia.*'([0-9]+)'.*'([0-9]+)'.*;/){|x| "/sites/#{@convar[$2]['weby_name']}/pages/#{@convar[$2]["noticias"][$1]}" if @convar[$2] }
        end 
        if str.match(/javascript:mostrar_informativo.*'([0-9]+)'.*'([0-9]+)'.*/)
          str.gsub!(/javascript:mostrar_informativo.*'([0-9]+)'.*'([0-9]+)'.*;/){|x| "/sites/#{@convar[$2]['weby_name']}/banners/#{@convar[$2]["informativos"][$1]}" if @convar[$2] }
        end 
        if str.match(/javascript:pagina_inicial.*'([0-9]+)'.*/)
          str.gsub!(/javascript:pagina_inicial.*'([0-9]+)'.*;/){|x| "/sites/#{@convar[$1]['weby_name']}" if @convar[$1] }
        end 
        if str.match(/javascript:mostrar_fale_conosco.*'([0-9]+)'.*/)
          str.gsub!(/javascript:mostrar_fale_conosco.*'([0-9]+)'.*;/){|x| "/sites/#{@convar[$1]['weby_name']}/feedbacks/new" if @convar[$1] }
        end 
        if str.match(/.*uploads.*\/([0-9]+)\/(.*)/)
          str.gsub!(/".*uploads.*\/([0-9]+)\/(.*)"/){|x| "/uploads/#{$1}/original_#{$2}" if @convar[$1] }
        end 
        return str 
      end 
    end 
    # Destrutor
    def finalize
      @con_this.close()
      @con_weby.close()
      File.open('convar.yml', 'w') do |out|
      YAML::dump(@convar, out)
      end
    end
end

class Migrate_files
  def initialize(from, to, id=[])
    # Coneção com banco
    if not File.exist?("./config-migrate.yml")
      puts "É necessário criar o arquivo config-migrate.yml com as diretivas de conexão."
      print "Exemplo:\nthis:\n  adapter: postgresql\n  host: localhost\n  database: this\n  username: this\n  password: senha_this\n\nweby:\n  adapter: postgresql\n  host: localhost\n  database: weby\n  username: weby\n  password: senha_weby\n"
      exit
    end
    # Arquivo de conversão necessário
    if not File.exist?("./convar.yml")
      puts "Deve existir o arquivo convar.yml"
      exit
    end
    @config = YAML::load(File.open("./config-migrate.yml"))
    @convar = YAML::load(File.open("./convar.yml"))
    @con_weby = PGconn.connect(@config['weby']['host'],nil,nil,nil,@config['weby']['database'],@config['weby']['username'],@config['weby']['password'])
    @folders = ['topo', 'imgd', 'banners', 'files']
    @ids = id
    from += '/' if from[-1] != '/'
    to += '/' if to[-1] != '/'
    @from = from
    @to = to
  end

  # Função retirada do paperclip
  def content_type file
    # Infer the MIME-type of the file from the extension.
    type = (file.match(/\.(\w+)$/)[1] rescue "octet-stream").downcase
    case type
      when %r"jp(e|g|eg)"            then "image/jpeg"
      when %r"tiff?"                 then "image/tiff"
      when %r"png", "gif", "bmp"     then "image/#{type}"
      when "txt"                     then "text/plain"
      when %r"html?"                 then "text/html"
      when "js"                      then "application/js"
      when "csv", "xml", "css"       then "text/#{type}"
    end
  end

  def copy_files
    if @ids.empty?
      # Descobre os ids dos sites
      ls = `ls #{@from + @folders.first}`
      ls = Iconv.conv("UTF-8//IGNORE","ASCII","#{ls}")
      ls.split("\n").each do |f|
        # Dentro de cada pasta teremos os ids dos sites
        # desde que  nome da pasta seja apenas números
        if f.scan(/\D/).empty?
          @ids << f
        end
      end
    end

    puts "ids = #{@ids}"
    # Para cada id de site conhecido
    @ids.each do |id|
      #id = id.to_s
      if @convar[id].nil? || @convar[id]['weby'].nil?
        next
      end

      destino = @to + @convar[id]['weby']
      # Se a pasta destino ainda não existe
      Dir.mkdir("#{destino}") unless Dir.exists?("#{destino}")

      # Verifica cada pasta conhecida
      @folders.each do |folder|
        temp_from = @from + folder + '/' + id + '/'

        # Remove todos subdiretorios
        dirs_to_flat = [temp_from]
        while !dirs_to_flat.empty?
          current_dir = dirs_to_flat.pop

          `find #{current_dir} -maxdepth 1 -mindepth 1 -type f`.split("\n").each do |file|
            `cp "#{file}" #{destino}/`
          end
          `find #{current_dir} -maxdepth 1 -mindepth 1 -type d`.split("\n").each do |dir|
            dirs_to_flat << dir
          end
        end
      end

      # Cria uma entrada para repositories no convas caso essa ainda não exista
      if @convar[id]["repositories"].nil?
        @convar[id]["repositories"] = []
      end

      # Registra cada arquivo na base
      `find #{destino} -maxdepth 1 -mindepth 1 -type f -not -iname "original_*" -not -iname "medium_*" -not -iname "little_*" -not -iname "mini_*"`.split("\n").each do |file|
        
        # Verifica se o arquivo já existe no canvar, ou seja, se ele já foi migrado
        unless @convar[id]["repositories"].index(file).nil?
          next
        # Se ainda não existe, coloca o arquivo na lista
        else
          @convar[id]["repositories"].push file
        end
        
        file_name = file.slice(file.rindex("/").to_i + 1, file.size)
        repository_id = create_repository(file, @convar[id]['weby'])

        if(file_name == "topo.jpg" || file_name == "topo.gif" || file_name == "topo.png")
            sql = "UPDATE sites SET top_banner_id='#{repository_id}' WHERE id='#{id}'"
            @con_weby.exec(sql)
            puts sql
            next
        end

        file_info = file_name.match(/([a-zA-Z]{3,})(\d*)[a-zA-Z_]*.[a-zA-Z_]{3,}$/)
        puts "file_info = #{file_info}, file_info.size: #{file_info.size}" unless file_info.nil?

        if(!file_info or file_info.size < 3)
          next
        end
        puts "file_info[1] = #{file_info[1]}, file_inf[2] = #{file_info[2]}"
        type,original_id = "#{file_info[1]}", "#{file_info[2]}"

        if (type == 'banner' or type == 'inf')
          tabela = 'banners'
          id_weby = @convar[id]['informativos'][original_id] if @convar[id]['informativos'][original_id]
        else
          # Se não for informativo, é uma página
          tabela = 'pages'
          # Do tipo evento?
          if type == 'evento'
            id_weby = @convar[id]['eventos'][original_id] if @convar[id]['eventos'][original_id]
          # Ou do tipo noticia?
          elsif type == 'noticia'
            id_weby = @convar[id]['noticias'][original_id] if @convar[id]['noticias'][original_id]
          # Se não for nehum dos tipos: continua o loop
          elsif id_weby.nil?
            next
          end
        end

        puts "type: #{type}, original_id: #{original_id}, id_weby: #{id_weby}, repository_id: #{repository_id}"
        if not repository_id.nil? and not id_weby.nil?
          sql = "UPDATE #{tabela} SET repository_id='#{repository_id}' WHERE id='#{id_weby}'"
          @con_weby.exec(sql)
          puts sql
        end

        # Renomeia o arquivo para o padrao do paperclip
        puts `mv #{file} #{destino}/original_#{file_name}`
      end
    end
  end

  def create_repository(file, site_id)
    #puts "file: #{file}, site_id: #{site_id}"
    file_name = file.slice(file.rindex('/').to_i + 1, file.size)
    file_name = @con_weby.escape(file_name) if file_name
    file_type = content_type file
    file_size = File.new(file).size
    descricao = ""
    #descricao = "#{file_name}"
 
    sql = "INSERT INTO repositories(site_id,created_at,updated_at,archive_file_name,archive_content_type,archive_file_size,archive_updated_at,description) VALUES ('#{site_id}','#{Time.now}','#{Time.now}','#{file_name}','#{file_type}','#{file_size}','#{Time.now}','#{descricao}') RETURNING id"
  
    repository = @con_weby.exec(sql)
    puts "\t\t(#{repository[0]['id']}) #{sql}"
    repository[0]['id']
  end

  # move arquivos 'soltos' para a posta temp
  def move_temp
    puts "Movendo arquivos avulsos"
    
    to_move = (Dir.entries(@from) - ['.', '..', '.svn']) - @folders
    if to_move.size > 0
      temp_folder = "#{@to}temp"

      Dir.mkdir("#{temp_folder}") unless Dir.exists?("#{temp_folder}")
      to_move.each do |d|
        puts `cp -urv "#{@from + d}" "#{temp_folder}"`
      end
    end
  end
  # Destrutor
  def finalize
    @con_weby.close()
    File.open('convar.yml', 'w') do |out|
    YAML::dump(@convar, out)
    end
  end
end

def use_mode
  puts "Modo de usar:\n #{__FILE__} [--no-migrate-db] [--dir-uploads-this /path/upload/this --dir-uploads-weby /path/upload/weby]"
  exit
end

if no_migrate_db = ARGV.index('--no-migrate-db')
  puts "A base de dados não será migrada!"
else 
  this2weby = Migrate_this2weby.new
  this2weby.migrate_this
  this2weby.finalize
end

if (up_this = ARGV.index('--dir-uploads-this')) and (up_weby = ARGV.index('--dir-uploads-weby'))
  unless up_this.nil?
    from_aux = ARGV[up_this.to_i+1]
    if (from_aux and File.directory?(from_aux))
      from = from_aux
    else
      puts "Erro no diretório de origem."
      use_mode 
    end
  end
  unless up_weby.nil?
    to_aux = ARGV[up_weby.to_i+1]
    if (to_aux and File.directory?(to_aux))
      to = to_aux
    else
      puts "Erro no diretório de destino."
      use_mode
    end
  end

  move = Migrate_files.new(from, to)
  move.copy_files
  move.move_temp
  move.finalize
end
