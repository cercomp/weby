module RepositoryHelper
  attr_accessor :file, :format, :options, :size, :thumbnail

  def weby_file_view(file, format, width = nil, height = nil, options = {as: 'link'})
    @file, @format, @width, @height, @options = file, format, width, height, options
    make_thumbnail!
    send("#{@options[:as]}_viewer")
  end

  # Retorna quais os tipos de arquivos existentes em um Site
  # Recebe um objeto do tipo Site
  def load_mime_types(site)
    mime_types = site.repositories.except(:order).
      map{|t| t.archive_content_type }.
      tap{|mime_type| mime_type.uniq!}.
      tap{|mime_type| mime_type.delete("")}.
      collect!{ |m| m.split('/') }.sort

    hash = Hash.new{|hash,key| hash[key] = Array.new}

    mime_types.each do  |type, subtype|  
      hash[type] << [subtype, "#{type}/#{subtype}"]
    end

    hash
  end

  private
  def make_thumbnail!
    @file.reprocess!
    if file.archive_content_type.empty?
      @thumbnail = "false.png"
    else
      if mime_type.first == "image"
        if mime_type.last.include?("svg") 
          @format = :original 
          clean_size!
        end

        @thumbnail = @file.archive.url(@format)
      else
        @thumbnail = mime_image
        clean_size!
      end
    end
  end

  def link_viewer
    raw link_to(image_viewer, @options[:url] || @file.archive.url, target: '_blank')
  end

  def image_viewer
    width = @width.blank? ? nil : @width
    height = @height.blank? ? nil : @height
    image = image_tag(@thumbnail,
                  alt: @options[:alt] || @file.description,
                  title: @options[:title] || @file.description)
    # Tratamento para IE8.
    if width
      image.gsub!("/>", " width='#{width}' />")
    end
    if height
      image.gsub!("/>", " height='#{height}' />")
    end

    raw image
  end

  def mime_type
    @file.archive_content_type.split('/')
  end

  def mime_image
    "mime_list/#{CGI::escape(mime_type.last)}.png"
  end

  def clean_size!
    @size.delete!('#') if @size
  end

end

