#!/home/danilo/.rvm/rubies/default/bin/ruby

# Copia os arquivos de uploads do this para o Weby
#

# É esperado dois argumentos, o caminho paraa pasta do this
# e outra para a pasta do webyge
if ARGV.count != 2
  puts "Modo de usar:\n" +
    "\t\033[1mfile_mover\033[0m \033[4mTHIS_PATH\033[0m \033[4mWEBY_PATH\033[0m"
  exit
end

cpath = `pwd`.chomp + '/' # current path

FROM = ARGV[0] || cpath + 'files_init_path/'
TO   = ARGV[1] || cpath + 'files_end_path/'
VERBOSE = TRUE

class Mover

  @folders  = ['banners/', 'topo/']
  @files = @ids = []
  @id_map = {'0' => '0new', '1' => '1new', '3' => '2new', }
  
  def self.print_ids
    puts @ids
  end

  # Descobre os ids dos sites
  `ls #{FROM + @folders.first}`.split("\n").each do |f|
    # Dentro de cada pasta teremos os ids dos sites
    # desde que  nome da pasta seja apenas números
    if f.scan(/\D/).empty?
      @ids << f
    end
  end

  def self.copy_files
    # Para cada id de site conhecido
    @ids.each do |id|
      # Se a pasta destino ainda não existe
      `mkdir #{TO + @id_map[id]}` unless Dir.exists?('#{TO + @id_map[id]}')

      # Verifica cada pasta conhecida
      @folders.each do |folder|
        puts `cp -vr #{FROM + folder + id + '/*'} #{TO + @id_map[id]}`
      end
    end
  end

end

Mover.copy_files
