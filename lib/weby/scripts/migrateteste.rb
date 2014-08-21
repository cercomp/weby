
# Consertando erros da migração
#def treat(obj,field)
#  if obj
#    obj.send(field).gsub(/(['"])\/uploads\/([0-9]+)\//){|x| "#{$1}/uploads/#{obj.site_id}/" if $2 != obj.site_id}
#  end
#end

#def treat(obj,field)
#  if obj
#    obj.send(field).gsub(/'\/pages\/([0-9]+)'/){|x| "/pages/#{$1}/"}
#  end
#end

#http://files/95/fluxo_atual.pdf_www2.catalao.ufg.br

#def treat(obj,field)
#  if obj
#    obj.send(field).gsub(/http:\/\/files\/[0-9]+\/(.+)_www2\.catalao\.ufg\.br/){|x| "/uploads/#{obj.site_id}/original_#{$1}"}
#  end
#end

#def treat_menu(obj,field)
#  if obj
#    obj.send(field).gsub(/^\/uploads\/([0-9]+)\//){|x| "/uploads/#{obj.menu.site_id}/" if $1 != obj.menu.site_id}
#  end
#end

#/admin/pages/54167/'/pages/54166'

#s = Site.where("id >= 496 and id <= 615")
#s.each do |site|
#  site.pages.each do |page|
#    page.url = treat(page, :url)
#    page.i18ns.each do |i18n|
#      i18n.text = treat(page, :text)
#      i18n.summary = treat(page, :summary)
#    end
#    page.save
#  end
##  site.menu_items.each do |item|
##    item.update_attributes(url: treat_menu(item, :url))
##  end
#end

# Outros testes
#! /usr/bin/env ruby
# coding: UTF-8
#
# Script de migração da base de dados This para Weby.
#
require 'rubygems'
require 'pg'
require 'yaml'
require 'cgi'
require 'htmlentities'
#require 'iconv'
require 'pp'
require 'mime/types'
require 'csv'

@config = YAML::load(File.open("config-migrate.yml"))
  @con_weby = PGconn.connect(@config['weby']['host'],nil,nil,nil,@config['weby']['database'],@config['weby']['username'],@config['weby']['password'])

  # Tratamento de caracteres
  def treat(string)
    unless string.nil?
      # src="http://www2.catalao.ufg.br/uploads/files/106/image/fotos%20banquete%20de%20livros/DSC_0062.JPG"
      # href=\"http://www2.catalao.ufg.br/uploads/files/90/DECLARA____O_DE_CI__NCIA_DE_NORMAS_E_DISPONIBILIDADE-mod.pdf">
      # <a href="http://www.ufg.br/uploads/files/UFG_em_n__meros_2010_12_07.pdf">
      puts string
      puts "###################################################################################"

      if string.match(/['"]+http.*?ufg.*?\/uploads\/[^\/]*\/[^\/]*\/.*?['"]+/)
          puts "primeiro"
          string.gsub!(/["']+http.*?ufg.*?\/uploads\/[^\/]*\/[^\/]*\/([^\/].*?)['"]+/){|x| "\"/uploads/1/original_#{$1}\""}
      elsif string.match(/['"]http.*?ufg.*?\/uploads\/[^\/]*\/[^\/"'].*?['"]/)
        puts "segundo"
          string.gsub!(/src=["']http.*?ufg.*?\/uploads\/[^\/]*\/([^\/"']*)['"]/){|x| "src=\"/uploads/1/original_#{$1}\""}
      elsif string.match(/.*?ufg.*?\/uploads\/.*?[^0-9]\/(.*?)/)
        puts "terceiro"
        string.gsub!(/.*?ufg.*?\/uploads\/.*\/(.*)/){|x| "/uploads/1/original_#{$1}"}
      end

      if string.match(/src=['"]http.*?ufg.*?\/uploads\/[^\/]*\/[^\/"'].*?['"]/)
        puts "segundo fora"
          string.gsub!(/src=["']http.*?ufg.*?\/uploads\/[^\/]*\/([^\/"']*)['"]/){|x| "src=\"/uploads/1/original_#{$1}\""}
      end
      # javascript:mostrar_pagina(357);
      if string.match(/javascript:mostrar_pagina\([0-9]+\)/)
        string.gsub!(/javascript:mostrar_pagina\(([0-9]+)\);/){|x| "/pages/#{@convar_ufg["1"]["paginas"][$1]}" if @convar_ufg["1"] }
      end
      #javascript:mostrar_pagina('24');
      if string.match(/javascript:mostrar_pagina\('[0-9]+'\);/)
        string.gsub!(/javascript:mostrar_pagina\('([0-9]+)'\);/){|x| "/pages/#{@convar_ufg["1"]["paginas"][$1]}" if @convar_ufg["1"] }
      end


      # javascript:mostrar_noticia('10355');
      if string.match(/javascript:mostrar_noticia\('([0-9]+)'\)/)
        string.gsub!(/javascript:mostrar_noticia\('([0-9]+)'\);/){|x| "/pages/#{@convar_ufg["1"]["noticias"][$1]}" if @convar_ufg["1"] }
      end
      # javascript:mostrar_informativo('6123');
      if string.match(/javascript:mostrar_informativo\('([0-9]+)'\)/)
        string.gsub!(/javascript:mostrar_informativo\('([0-9]+)'\);/){|x| "\"/banners/#{@convar_ufg['1']["informativos"][$1]}'" if @convar_ufg['1']}
      end

      # javascript:mostrar_menu('179','esq');
      # javascript:mostrar_menu('183','esq');
      if string.match(/javascript:mostrar_menu\('([0-9]+)'.*\)/)
#        string.gsub!(/javascript:mostrar_menu\('([0-9]+)'.*\);/){|x| "/pages/#{$1}"}
        string.gsub!(/["']javascript:mostrar_menu\('([0-9]+)'.*\);['"]/){|x| "/pages/#{@convar_ufg["1"]["paginas_menus"][$1]}" if @convar_ufg["1"] }
      end
      if string.match(/javascript:pagina_inicial.*?([0-9]+).*?/)
        string.gsub!(/javascript:pagina_inicial.*?([0-9]+).*?;/){|x| "/" if @convar_ufg[$1] }
      elsif string.match(/javascript:pagina_inicial.*?/)
        string.gsub!(/javascript:pagina_inicial(.*?);/){|x| "/"}
      end
      if string.match(/javascript:mostrar_fale_conosco.*?\(\).*?/)
        string.gsub!(/javascript:mostrar_fale_conosco.*?\(\).*?;/){|x| "/feedback"}
      end

      if string.match(/javascript:mostrar_evento\(.*?[0-9]+.*?'\)/)
        string.gsub!(/javascript:mostrar_evento\(.*?([0-9]+).*?\);/){|x| "/pages/#{@convar_ufg['1']["paginas"][$1]}" if @convar_ufg['1'] }
      end

      #if string.match(/['"]http:\/\/www.ufg.*?\/.*?\/.*?['"]/)
      #  string.gsub!(/['"]http:\/\/www.(.*?ufg.*?)\/.*?\/([^\/"'].*?)\/?+['"]/){|x| "http://#{$1}_#{$2}" }
      #end
      #if string.match(/['"]+http:\/\/www.ufg.*?\/.*?\/+['"]/)
      #  string.gsub!(/['"]+http:\/\/www.(.*?ufg.*?)\/([^\/"'].*?)\/?+['"]/){|x| "http://#{$1}_#{$2}" }
      #end

      if string.match(/http:\/\/www.ufg.*?\/page.php\/.*?[0-9]+?/)
        string.gsub!(/http:\/\/www.ufg.*?\/pages.php\/.*?([0-9]+)+/){|x| "/pages/#{@convar_ufg['1']["paginas"][$1]}" if @convar_ufg['1'] }
      end

      if string.match(/http:\/\/www.ufg.br\/page.php\?menu_id=/)
        puts "terceiro"
        string.gsub!(/["]http:\/\/www.ufg.br\/page.php\?menu_id=([0-9]+).*["]/){|x| "\"/pages/#{@convar_ufg['1']["paginas_menus"][$1]}\"" if @convar_ufg['1'] }
      end

      puts string
      puts "###################################################################################"
    end
  end

html = <<EOF
    <p><span class="subtitulo">Ciências Exatas e da Terra</span></p>
<ul>
    <li><a href="javascript:mostrar_menu('196','esq');">Ciência da Computação</a></li>
    <li><a href="javascript:mostrar_menu('197','esq');">Física</a></li>
    <li><a href="javascript:mostrar_menu('198','esq');">Matemática</a></li>
    <li><a href="javascript:mostrar_menu('199','esq');">Química</a></li>
    <li><a href="http://www.ufg.br/page.php?menu_id=308&amp;pos=esq">Estatística</a></li>
    <li><a href="javascript:mostrar_menu('314','esq');">Ciências Geoambientais</a></li>
    <li><a href="javascript:mostrar_menu('309','esq');">Sistemas de Informação</a></li>
    <li><a href="javascript:mostrar_menu('320','esq');">Matemática industrial</a></li>
    <li><a href="javascript:mostrar_menu('323','esq');">Engenharia de software</a></li>
</ul>
<p>&nbsp;</p>
EOF

  html = "javascript:mostrar_evento('10511');"
if File.exists?("./convar_ufgbr.yml")
  @convar_ufg = YAML::load(File.open("./convar_ufgbr.yml"))
else
  @convar_ufg = {} # Variável de conversão
end
treat(html)
  #treat(formulario)
