module RepositoryHelper
  attr_accessor :file, :format, :options, :size, :thumbnail

  #
  # Returns the image's HTML
  def weby_file_view(file, format, width = nil, height = nil, options = {}, fallback = false)
    options[:as] ||= 'link'
    @file, @format, @width, @height, @options = file, format, width, height, options
    if @file
      make_thumbnail!
      send("#{@options[:as]}_viewer")
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

  # Input: Site object
  # Output: Returns all the MIME types of an site files
  def load_mime_types(site, only = [])

    if @site
      mime_types = site.repositories.
        content_file(only).
        map { |t| t.archive_content_type }.
        tap { |mime_type| mime_type.uniq! }.
        tap { |mime_type| mime_type.delete('') }.
        map! { |m| m.split('/') }.sort
    else
      mime_types = Repository.all.
      content_file(only).
      map { |t| t.archive_content_type }.
      tap { |mime_type| mime_type.uniq! }.
      tap { |mime_type| mime_type.delete('') }.
      map! { |m| m.split('/') }.sort
    end
    hash = Hash.new { |subhash, key| subhash[key] = Array.new }

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

    options.merge!(link_title: link_title,
                   place_name: place_name,
                   field_name: field_name,
                   selected: selected)
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
    # @file.reprocess -- Removed in order to use several back-ends
    if file.archive_content_type.empty?
      @thumbnail = empty_mime
    else
      if mime_type.first == 'image'
        @format = :o if mime_type.last.include?('svg')

        @thumbnail = @file.archive.url(@format)
      else
        @thumbnail = mime_image
      end
    end
  end

  def link_if_viewer
    if @options[:url]
      @link_title = @options[:title].presence || guess_title_by(@options[:url])
      link_to(image_viewer, @options[:url],
                target: @options[:target],
                data: @options[:data],
                title: @link_title,
                class: @options[:link_class])
    else
      image_viewer
    end
  end

  def link_viewer
    @link_title = if @options[:url]
      @options[:title].presence || guess_title_by(@options[:url])
    else
      t('link_to_file')
    end
    raw link_to(image_viewer, @options[:url] || @file.archive.url,
                target: @options[:target],
                data: @options[:data],
                title: @link_title,
                class: @options[:link_class])
  end

  def image_viewer
    img_opt = {
      alt: @file.description,
      title: @link_title.present? ? nil : (@options[:title].presence || @file.title)
    }
    size = style_for_dimension @width, @height
    img_opt[:style] = @options[:style] ? "#{@options[:style]}#{size}" : size
    img_opt[:id] = @options[:id] if @options[:id]
    img_opt[:class] = @options[:image_class] if @options[:image_class]
    img_opt[:data] = @options[:data] if @options[:data].present?
    img_opt[:aria] = @options[:aria] if @options[:aria].present?
    begin
      image = image_tag(@thumbnail, img_opt)
    rescue
      image = image_tag(empty_mime, img_opt)
    end

    raw image
  end

  def mime_type
    # FIX this FIX
    return 'application/pdf'.split('/') if @file.archive_file_name.match(/\.pdf$/) && @file.archive_content_type.match(/(\-download|save)$/)
    return 'application/msword'.split('/') if @file.archive_file_name.match(/\.doc$/) && @file.archive_content_type.match(/(\-download|save)$/)
    @file.archive_content_type.split('/')
  end

  def mime_image
    file = "mime_list/#{CGI.escape(mime_type.last)}.png"
    Weby::Assets.find_asset(file) ? file : empty_mime
  end

  def empty_mime
    'mime_list/VAZIO.png'
  end

  def full_image_url(repository)
    "http://#{request.host_with_port}#{repository.archive.url}"
  end

  def image_size_picker(form_builder)
    render partial: 'sites/admin/repositories/image_size_picker', locals: { f: form_builder }
  end

  def repository_partial
    %w(list thumbs).include?(session[:repository_view]) ?
    session[:repository_view] : 'thumbs'
  end

  def banners_partial
    %w(list thumbs).include?(session[:banners_view]) ?
    session[:banners_view] : 'list'
  end

  def format_for_custom(width, height, _repository)
    Repository.attachment_definitions[:archive][:styles].each do |name, value|
      size = value.split('x') if value.match(/^\d+x\d+$/)
      if size
        if width.to_i + height.to_i > 0 and width.to_i <= size[0].to_i && height.to_i <= size[1].to_i
          return name
        end
      end
    end
    :o
  end

  def guess_title_by url
    common_pages.each do |static_page|
      return static_page[:title] if url.strip == static_page[:url]
    end
    case url.to_s
    when /^https?:\/\/(www\.)?ufg.br\/?$/
      'Portal UFG'
    when /^https?:\/\/(www\.)?sic\.ufg.br\/?$/
      'Portal Acesso à Informação'
    when /^\/feedback/
      'Fale Conosco'
    when /^https?:\/\/(www\.)?instagram\.com/
      'Instagram'
    when /^https?:\/\/(www\.)?facebook\.com/
      'Facebook'
    when /^https?:\/\/(www\.)?twitter\.com/
      'Twitter'
    when /^https?:\/\/(www\.)?linkedin\.com/
      'Linkedin'
    when /^https?:\/\/(www\.)?youtube\.com/
      'Youtube'
    when /^https?:\/\/(www\.)?tvufg\.org\.br/
      'TV UFG'
    when /^https?:\/\/(www\.)?radio\.ufg\.br\//
      'Rádio UFG'
    when main_app.site_url(subdomain: current_site)
      'Página Inicial'
    else
      nil
    end
  end

  def dimension_for_size(size)
    dimension = Repository.attachment_definitions[:archive][:styles][size.to_sym]

    return dimension.split('x') if dimension && dimension.match(/^\d+x\d+$/)
  end

  def style_for_dimension(width, height)
    size = ''
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

      link_to image_tag('weby-filler.png', img_opt), options[:url]
    else
      weby_file_view(file, format, width, height, options)
    end
  end

  def render_user_content str
    if ENV['STORAGE_HOST'].present?
      str = str.to_s.gsub(/="\/up\//, "=\"//#{ENV['STORAGE_HOST']}/#{ENV['STORAGE_BUCKET']}/up/")
    end
    str.html_safe
  end

  def externalize_links(text, url)
    text.gsub(/(src|href)="\/([^\/])/, "\\1=\"#{url}\\2").html_safe
  end
end
