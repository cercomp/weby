#! /usr/bin/env ruby
# coding: UTF-8

DEBUG = 1

# Copia os arquivos de uploads do this para o Weby
#
require 'yaml'

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

# Cria o diretório que conterá os arquivos na nova estrutura
begin
  Dir.mkdir(TO)
  TO << '/'

rescue
  puts "Não foi possível criar o diretório de saída."
  exit
  
end

class Mover

  @folders  = ['banners', 'files', 'imgd', 'topo']
  @files = @ids = []

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
      if MAP[id]['weby'].nil?
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
    puts "debug\n#{to_move}"
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
