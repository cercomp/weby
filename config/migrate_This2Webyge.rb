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
 
#authlogic = Authlogic::ActsAsAuthentic::Base::Config
class Migrate_this2weby
  def initialize(verbose=true)
    # Coneção com os dois bancos
    if not File.exist?("config-migrate.yml")
      puts "É necessário criar o arquivo config-migrate.yml com as diretivas de conexão."
      puts "Exemplo:
this:
  adapter: postgresql
  host: localhost
  database: this
  username: this
  password: senha_this

weby:
  adapter: postgresql
  host: localhost
  database: weby
  username: weby
  password: senha_weby
"
      exit
    end
    @config = YAML::load(File.open("./config-migrate.yml"))
    @con_this = PGconn.connect(@config['this']['host'],nil,nil,nil,@config['this']['database'],@config['this']['username'],@config['this']['password'])
    @con_weby = PGconn.connect(@config['weby']['host'],nil,nil,nil,@config['weby']['database'],@config['weby']['username'],@config['weby']['password'])
    @verbose = verbose
    @param = "WHERE site_id=17"
  end

  def migrate_this_usuarios
    puts "Migrando tabela this.usuarios para weby.users...\n" if @verbose
    select_usuarios = "SELECT * FROM usuarios #{@param}"
    puts "\t#{select_usuarios}\n" if @verbose
    users_this = @con_this.exec(select_usuarios)
    # Laço de repetição
    users_this.each do |u_this|
      # Separa o primeiro nome do resto
      first_name,last_name = u_this['nome'].split(" ",0)
      # Populando weby.users
      insert_usuario = "INSERT INTO users (register,first_name,last_name,login,crypted_password,email,phone,mobile,status,password_salt,persistence_token,single_access_token,perishable_token) VALUES ('#{u_this['matricula']}','#{first_name}','#{last_name}','#{u_this['login_name']}','#{u_this['senha']}','#{u_this['email']}','#{u_this['telefone']}','#{u_this['celular']}','#{u_this['status']}','#{Authlogic::Random.friendly_token}','#{Authlogic::Random.hex_token}','#{Authlogic::Random.friendly_token}','#{Authlogic::Random.friendly_token}')"
      puts "\t\t#{insert_usuario}\n" if @verbose
      @con_weby.exec(insert_usuario)
    end
    puts "Limpando tabela.\n" if @verbose
    users_this.clear()
  end

  def migrate_this_sites
    puts "Migrando tabela this.sites para weby.sites...\n" if @verbose
    select_sites = "SELECT * FROM sites #{@param}"
    puts "\t#{select_sites}\n" if @verbose
    sites_this = @con_this.exec(select_sites)
    # Laço de repetição
    sites_this.each do |s_this|
      insert_site = "INSERT INTO sites (name,url,description) VALUES ('#{s_this['nm_site']}','#{s_this['caminho_http']}','#{s_this['nm_site']}') RETURNING id"
      site = @con_weby.exec(insert_site)
      puts "\t\t(#{site[0]['id']}) #{insert_site}\n" if @verbose

      # Migrando Tabela: this.menu_[direito,esquerdo,superior,inferior] => weby.menus
      select_menu_d = "SELECT * FROM menu_direito WHERE site_id='#{s_this['site_id']}'"# AND item_pai=0"
      puts "\t\t\t#{select_menu_d}\n" if @verbose
      menus_this_d = @con_this.exec(select_menu_d)
      # Agrupando por item_pai
      menus_this_d_groupby = menus_this_d.group_by{|i| i['item_pai']}
      # Laço this.menu_direito
      unless menus_this_d_groupby["0"].nil?
        menus_this_d_groupby["0"].each do |m_d|
          insert_menu = "INSERT INTO menus (title,link) VALUES ('#{m_d['texto_item']}','#{m_d['url']}') RETURNING id"
          menu_d = @con_weby.exec(insert_menu)
          puts "\t\t\t\t(#{menu_d[0]['id']}) #{insert_menu}\n" if @verbose
          insert_menu_p = "INSERT INTO sites_menus(site_id,menu_id,parent_id,side) VALUES ('#{site[0]['id']}','#{menu_d[0]['id']}',0,'auxiliary') RETURNING id"
          menu_d0 = @con_weby.exec(insert_menu_p)
          puts "\t\t\t\t#({menu_d0[0]['id']}) #{insert_menu_p}\n" if @verbose
          # Recursão
          deep_insert_menu(menus_this_d_groupby, m_d, site[0]['id'], menu_d0[0]['id'])
        end
      end
      #menus_this_e = @con_this.exec("SELECT * FROM menu_esquerdo WHERE site_id='#{site[0]['id']}' AND item_pai=0")
      #menus_this_s = @con_this.exec("SELECT * FROM menu_superior WHERE site_id='#{site[0]['id']}' AND item_pai=0")
      #menus_this_i = @con_this.exec("SELECT * FROM menu_inferior WHERE site_id='#{site[0]['id']}' AND item_pai=0")
      menus_this_d.clear()
      #menus_this_e.clear()
      #menus_this_s.clear()
      #menus_this_i.clear()
    end
    sites_this.clear()
  end

  def deep_insert_menu(sons, entry, site_id, menu_id)
    if sons["#{entry['id']}"].class.to_s == "Array"
      sons["#{entry['id']}"].each do |child|
        deep_insert_menu(sons, child, site_id, menu_id)
      end
    end
    insert_menu_sub = "INSERT INTO menus (title,link) VALUES ('#{entry['texto_item']}','#{@con_weby.escape(entry['url'])}') RETURNING id"
    menu_sub = @con_weby.exec(insert_menu_sub)
    puts "\t\t\t\t(#{menu_sub[0]['id']}) #{insert_menu_sub}\n" if @verbose
    insert_sites_menus = "INSERT INTO sites_menus(site_id,menu_id,parent_id,side) VALUES ('#{site_id}','#{menu_sub[0]['id']}','#{menu_id}','auxiliary')"
    @con_weby.exec(insert_sites_menus)
    puts "\t\t\t\t#{insert_sites_menus}\n" if @verbose
  end

  def finalize
    @con_this.close()
    @con_weby.close()
  end
end

this2weby = Migrate_this2weby.new
#this2weby.migrate_this_usuarios
this2weby.migrate_this_sites
this2weby.finalize
