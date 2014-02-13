module RepositoryHelper
  attr_accessor :file, :format, :options, :size, :thumbnail

  # Retorna html a ser exibido da imagem 
  # 
  def weby_file_view(file, format, width = nil, height = nil, options = {}, fallback = false)
    options[:as] ||= 'link'
    @file, @format, @width, @height, @options = file, format, width, height, options
    if @file
      make_thumbnail!
      send("#{@options[:as]}_viewer") # chama método http://ruby-doc.org/core-1.9.3/Object.html#method-i-send
    elsif fallback
      img_opt = {}
      img_opt[:alt] = @options[:alt] if @options[:alt]
      img_opt[:title] = @options[:title] if @options[:title]
      size = style_for_dimension @width, @height
      img_opt[:style] = @options[:style] ? "#{@options[:style]}#{size}" : size
      img_opt[:id] = @options[:id] if @options[:id]
      raw image_tag(empty_mime, img_opt)
    end
  end

  # Retorna quais os tipos de arquivos existentes em um Site
  # Recebe um objeto do tipo Site
  def load_mime_types(site, only = [])

    mime_types = site.repositories.
      content_file(only).
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

  # Used to include a partial in order to search for images
  def repository_dialog
    content_for :body_end do
      @repo_included = @repo_included.to_i + 1
      render('sites/admin/repositories/repository_search') if @repo_included == 1
    end
  end

  def repository_search(link_title, place_name, field_name, selected, options = {})
    options[:file_types] = [options[:file_types]].flatten
    
    options.merge!({ link_title: link_title,
                     place_name: place_name,
                     field_name: field_name,
                     selected: selected })
    repository_dialog
    render 'sites/admin/repositories/link_to_add_files', options
  end

  def link_to_add_files(local_assigns)
    if  local_assigns[:multiple]
      render 'sites/admin/repositories/link_to_add_files_multiple', local_assigns 
    else 
      render 'sites/admin/repositories/link_to_add_files_uniq', local_assigns 
    end 
  end

  private
  def make_thumbnail!
    @file.reprocess
    if file.archive_content_type.empty?
      @thumbnail = empty_mime
    else
      if mime_type.first == "image"
        if mime_type.last.include?("svg") 
          @format = :original 
        end

        @thumbnail = @file.archive.url(@format)
      else
        @thumbnail = mime_image
      end
    end
  end

  def link_viewer
    raw link_to(image_viewer, @options[:url] || @file.archive.url, target: @options[:target],
                data: @options[:data], class: @options[:link_class])
  end

  def image_viewer
    img_opt = {
      alt: @file.description,
      title: (@options[:title] || @file.description) }
    size = style_for_dimension @width, @height
    img_opt[:style] = @options[:style] ? "#{@options[:style]}#{size}" : size
    img_opt[:id] = @options[:id] if @options[:id]
    img_opt[:class] = @options[:image_class] if @options[:image_class]
    begin
      image = image_tag(@thumbnail, img_opt)
    rescue
      image = image_tag(empty_mime, img_opt)
    end

    raw image
  end

  def mime_type
    #FIX this FIX
    return "application/pdf".split("/") if (@file.archive_file_name.match(/\.pdf$/) && @file.archive_content_type.match(/(\-download|save)$/))
    return "application/msword".split("/") if (@file.archive_file_name.match(/\.doc$/) && @file.archive_content_type.match(/(\-download|save)$/))
    @file.archive_content_type.split('/')
  end

  def mime_image
    "mime_list/#{CGI::escape(mime_type.last)}.png"
  end

  def empty_mime
    "mime_list/VAZIO.png"
  end

  def full_image_url repository
    "http://#{request.host_with_port}#{repository.archive.url}"
  end

  def image_size_picker form_builder
    render partial: "sites/admin/repositories/image_size_picker", locals: {f: form_builder}
  end

  def repository_partial
    ['list','thumbs'].include?(session[:repository_view]) ?
    session[:repository_view] : 'thumbs'
  end

  def banners_partial
    ['list','thumbs'].include?(session[:banners_view]) ?
    session[:banners_view] : 'list'
  end

  def format_for_custom width, height, repository
    Repository.attachment_definitions[:archive][:styles].each do |name, value|
      size = value.split("x") if value.match(/^\d+x\d+$/)
      if size
        if width.to_i+height.to_i > 0 and width.to_i <= size[0].to_i && height.to_i <= size[1].to_i
          return name
        end
      end
    end
    :original
  end

  def dimension_for_size size
    dimension = Repository.attachment_definitions[:archive][:styles][size.to_sym]
    if dimension and dimension.match(/^\d+x\d+$/)
      return dimension.split('x')
    end
  end

  def style_for_dimension width, height
    size = ""
    size << "width:#{width}px; " if width
    size << "height:#{height}px; " if height
    size
  end

  def news_image(file, format, width = nil, height = nil, options = {})
    if file.nil?
      img_opt = {}
      size = style_for_dimension width, height
      img_opt[:style] = options[:style] ? "#{options[:style]}#{size}" : size
      img_opt[:id] = options[:id] if options[:id]
      img_opt[:class] = options[:image_class] if options[:image_class]

      link_to image_tag("weby-filler.png", img_opt), options[:url]
    else
      weby_file_view(file, format, width, height, options)
    end
  end
end
