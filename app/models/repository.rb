class Repository < ActiveRecord::Base
belongs_to :site

 has_attached_file :archive,
                   :styles => { :medium => "300X300", :thumb => "100X100"},
                   :url => "/images/:class/:attachment/:id/:style_:basename.:extension",
                   :default_url => "/images/default_image_arquive.png" 
                    
   #validates_attachment_content_type :mp3, :content_type => [ "image/bmp", "image/x-png", "image/pjpeg", "image/jpg", "image/jpeg", "image/png", "image/gif", 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ] 
   validates_attachment_presence :archive

end
