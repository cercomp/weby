#coding: utf-8
module ClippingHelper

  def news_image(file, format, width = nil, height = nil, options = {})
    if file.nil?
     link_to image_tag("weby-filler.png", width: width, height: height), options[:url]
    else
      weby_file_view(file, format, width, height, options)
    end
  end

end

