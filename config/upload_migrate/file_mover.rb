#! /usr/bin/env ruby
# coding: UTF-8

DEBUG = 1

# Copia os arquivos de uploads do this para o Weby
#
require 'yaml'

# Função retirada do paperclip
class Paperclip
  # Infer the MIME-type of the file from the extension.
  def self.content_type file
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
end

# É esperado pelo menos um argumento
#   - o caminho do arquivo .yml com o mapa dos ids dos sites,
#     do this para o weby
if ARGV.count < 1
  puts "Modo de usar:\n" +
    "\t\033[1mfile_mover\033[0m \033[4mYML_FILE\033[0m [\033[4mTHIS_PATH\033[0m]"
  exit
end

# Se o caminho do this não foi passado, verifica se o caminho atual
# é o mesmo do this
if !DEBUG and ARGV.count == 1
  unless Dir.exists?('uploads')
    puts "Este não é o diretório raiz do this:\n" +
      "\tCaso o segundo parâmetro seja omitido, este script deve ser executado " +
      "no diretório raiz do This2."
    exit
  end
end

cpath = `pwd`.chomp + '/' # current path

MAP     = open(ARGV[0]) {|f| YAML.load(f) }
FROM    = ARGV[1] || cpath + 'uploads/'
TO      = 'weby_structure'
VERBOSE = true
# TODO temporario
FILE    = File.new 'repositorie_inserts.sql', 'w'

# Cria o diretório que conterá os arquivos na nova estrutura
begin
  Dir.mkdir(TO)
  TO << '/'

rescue
  puts "Não foi possível criar o diretório de saída."
  exit
  
end

class Mover

  #@folders  = ['banners', 'files', 'imgd', 'topo']
  @folders  = ['banners']
  @ids = []

  def self.copy_files
    # Descobre os ids dos sites
    `ls #{FROM + @folders.first}`.split("\n").each do |f|
      # Dentro de cada pasta teremos os ids dos sites
      # desde que  nome da pasta seja apenas números
      if f.scan(/\D/).empty?
        @ids << f
      end
    end

    # Para cada id de site conhecido
    @ids.each do |id|
      if MAP[id].nil? || MAP[id]['weby'].nil?
        next
      end

      destino = TO + MAP[id]['weby']
      # Se a pasta destino ainda não existe
      Dir.mkdir("#{destino}") unless Dir.exists?("#{destino}")

      # Verifica cada pasta conhecida
      @folders.each do |folder|
        puts `cp -vr #{FROM + folder + '/' + id + '/*'} #{destino}`
      end

      #### Remove subpastas, trazendo todos os arquivos para a pasta principal
      # Busca por diretórios dentro das pastas
	    puts "Removendo diretórios internos da pasta \"#{destino}\""
      dirs = `find #{destino}/ -maxdepth 1 -mindepth 1 -type d`.split("\n")

      while dirs.count > 0
        d = dirs.pop
        puts `mv -v #{d}/* #{destino}/` if (Dir.entries(d) - ['.', '..']).size > 0
        # remove o diretório, já que não precisamos mais dele
        puts `rm -vr #{d}`
        
        # verfica novamente os diretórios
        dirs = `find #{destino}/ -maxdepth 1 -mindepth 1 -type d`.split("\n")
      end

      # Depois que todos os arquivos foram movidos, registra todos eles no banco
      files = `find "#{destino}" -maxdepth 1 -mindepth 1`.split("\n")
      db_registry(files, MAP[id]['weby'])

    end
  end

  def self.db_registry(files, site_id)
    puts "Criando as sqls para os arquivos do site #{site_id}(id)"

    files.each do |file|
      file_name = file.slice(file.rindex('/')+1, file.size)
      file_type = Paperclip.content_type  file
      file_size = File.new(file).size
      descricao = "Este arquivo ainda não possui descrição"

      sql = %Q{
insert into repositories(
  site_id,
  created_at,
  updated_at,
  archive_file_name,
  archive_content_type,
  archive_file_size,
  archive_updated_at,
  description
) 
values (
  #{site_id}, 
  '#{Time.now}',
  '#{Time.now}',
  '#{file_name}',
  '#{file_type}',
  '#{file_size}',
  '#{Time.now}',
  '#{descricao}'
);\n
}

      FILE.puts sql
      puts sql
    end
  end

	# compacta a pasta de saida
  def self.tar_dir
    tar_name = TO[0..-2] << '.tar.gz'
    `tar -zcvf #{tar_name} #{TO}`
  end

  # move arquivos 'soltos' para a posta temp
  def self.move_temp
    puts "Movendo arquivos avulsos"
    
    to_move = (Dir.entries(FROM) - ['.', '..']) - @folders
    if to_move.size > 0
      temp_folder = "#{TO}/temp"

      puts `mkdir #{temp_folder}`
      to_move.each do |d|
        d = Regexp.escape(d).gsub(/([:~!<>="])/,'\\\1')
        puts `cp -rv #{FROM + d} #{temp_folder}`
      end
    end
  end

end

Mover.copy_files
Mover.move_temp
Mover.tar_dir


