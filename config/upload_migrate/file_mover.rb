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

  @folders  = ['banners/', 'files/']
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
      destino = TO + MAP[id.to_i].to_s
      # Se a pasta destino ainda não existe
      Dir.mkdir("#{destino}") unless Dir.exists?("#{destino}")

      # Verifica cada pasta conhecida
      @folders.each do |folder|
        puts `cp -vr #{FROM + folder + id + '/*'} #{destino}`
      end
    end
  end

  def self.tar_dir
    tar_name = TO[0...-1] << '.tar.gz'
    `tar -zcvf #{tar_name} #{TO}`
  end

end

Mover.copy_files
Mover.tar_dir
