module RepositoriesHelper
  def show_repositories_list
    output = ''
    image = ''
    repositories_list = Repository.where(["site_id = ? ", @site.id])
    cont = 0

    repositories_list.each do |file|

      unless file.archive_content_type.include?("image") 
        if file.archive_content_type.include?("pdf") 
			 	image << (link_to image_tag "/images/pdf_file.png",:size => "80x80", :title => file.description, :alt => file.description).to_s
			  else 	
			   image << (link_to image_tag "/images/arquivo.gif",:size => "80x80", :title => file.description, :alt => file.description).to_s
			  end	
      else
        image << (link_to image_tag file.archive.url, :size => "80x80", :title => file.description, :alt => file.description).to_s
      end

      if cont%5 == 0
          output += '<p>'
      end
      
      output << '

      ' + image.to_s + '<input name="archive' + cont.to_s + '" type="checkbox" /> 
      '
      if cont%5 == 4
          output += '</p>'
      end

      cont += 1
      image = ''
    end
 
    return output
  end
end
