module RepositoryHelper
  attr_accessor :file, :format, :options, :size, :thumbnail

  def weby_file_view(file, format, width = nil, height = nil, options = {as: 'link'})
    @file, @format, @width, @height, @options = file, format, width, height, options
    if @file
      make_thumbnail!
      send("#{@options[:as]}_viewer") # chama método http://ruby-doc.org/core-1.9.3/Object.html#method-i-send
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

  def repository_search(link_title, place_name, field_name, selected, options = {})
    options[:file_types] = [options[:file_types]].flatten

    options.merge!({ link_title: link_title,
                     place_name: place_name,
                     field_name: field_name,
                     selected: selected })


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
    raw link_to(image_viewer, @options[:url] || @file.archive.url, target: @options[:target] || '_blank')
  end

  def image_viewer
    img_opt = {
      alt: (@options[:alt] || @file.description),
      title: (@options[:title] || @file.description) }
      img_opt[:width] = @width unless @width.blank?
      img_opt[:height] = @height unless @height.blank?
      img_opt[:id] = @options[:id] if @options[:id]
      image = image_tag(@thumbnail, img_opt)

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

