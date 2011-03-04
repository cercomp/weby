#!/home/danilo/.rvm/rubies/default/bin/ruby

# Copia os arquivos de uploads do this para o Weby
#

cpath = `pwd`.chomp + '/' # current path

FROM = ARGV[1] || cpath + 'files_init_path/'
TO   = ARGV[2] || cpath + 'files_end_path/'
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
      if f.scan(/\D/).empty?
        @ids << f
        #@files << @cur_path + FROM + f
      end
  end

  def self.copy_files
    # Para cada id de site conhecido
    @ids.each do |id|
      # Verifica cada pasta conhecida
      @folders.each do |folder|
        puts `cp -vr #{FROM + folder + id + '/*'} #{TO + @id_map[id]}`
      end
    end
  end

end

Mover.copy_files
