#coding: utf-8
module ClippingHelper

  def news_image(file, format, width = nil, height = nil, options = {})
    if file.nil?
     image_tag("weby-filler.png") 
    else
      weby_file_view(file, format, width, height, options)
    end
  end

end

