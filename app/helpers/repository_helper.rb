module RepositoryHelper

  def image_field(file, type, size)
    make_thumb(file, type)
    image_tag(file.archive.url(type), :alt => file.description, :size => size)
  end

  # Define qual imagem de exibição será mostrada para o arquivo.
  # Recebe um objeto do tipo Repository
  def archive_type_image(file, type, size=nil)
    # Gera um thumb se ele não existir
    make_thumb(file, type)

    if file.archive_content_type.empty?
      image_tag("false.png")
    else
      mime_type = get_mime(file)
      if mime_type[0] == "image"
        type = :original if mime_type[1].include?("svg") 
        size = nil unless mime_type[1].include?("svg")

        link_to_image(file, file.archive.url(type), size)
      else
        link_to_image(file, "mime_list/#{CGI::escape(mime_type[1])}.png", size)
      end
    end 
  end

  private
  def make_thumb(file, type)
    file.archive.reprocess! if File.file?(file.archive.path) and not File.file?(file.archive.path(type)) and file.image?
  end

  def get_mime(file)
    file.archive_content_type.split('/')
  end

  def link_to_image(file, image, size)
    link_to(image_tag(image, alt: file.description, size: size),
            file.archive.url,
            title: file.description,
            target: '_blank')
  end
end
