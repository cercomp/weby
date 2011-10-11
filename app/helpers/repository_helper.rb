module RepositoryHelper
  attr_accessor :file, :format, :options, :size, :thumbnail

  def weby_file_view(file, format, size = nil, options = {as: 'link'})
    @file, @format, @size, @options = file, format, size, options
    make_thumbnail!
    send("#{@options[:as]}_viewer")
  end

  private
  def make_thumbnail!
    @file.archive.reprocess! if need_reprocess?
    if file.archive_content_type.empty?
      @thumbnail = "false.png"
    else
      if mime_type.first == "image"
        @format, @size = :original, nil if mime_type.last.include?("svg") 

        @thumbnail = @file.archive.url(@format)
      else
        @thumbnail = mime_image
        @size = "64x64"
      end
    end
  end

  def link_viewer
    raw link_to(image_viewer, @file.archive.url, title: @file.description, target: '_blank')
  end

  def image_viewer
    raw image_tag(@thumbnail, alt: @file.description, size: @size, title: @file.description)
  end

  def mime_type
    @file.archive_content_type.split('/')
  end

  def mime_image
    "mime_list/#{CGI::escape(mime_type.last)}.png"
  end

  def need_reprocess?
    not File.file?(@file.archive.path(@format)) and 
      @file.image?
  end
end
