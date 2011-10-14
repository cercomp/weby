module RepositoryHelper
  attr_accessor :file, :format, :options, :size, :thumbnail

  def weby_file_view(file, format, size = nil, options = {as: 'link'})
    @file, @format, @size, @options = file, format, size, options
    make_thumbnail!
    send("#{@options[:as]}_viewer")
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
    raw image_tag(@thumbnail,
                  alt: @options[:alt] || @file.description,
                  size: @size,
                  title: @options[:title] || @file.description)
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
