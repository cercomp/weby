class Repository < ActiveRecord::Base
belongs_to :site

attr_accessor :site_id



has_attached_file :archive,
                   :url => "/uploads/:site_id/:class/:attachment/:id/:style_:basename.:extension"
                    

#validates_attachment_content_type :mp3, :content_type => [ "image/bmp", "image/x-png", "image/pjpeg", "image/jpg", "image/jpeg", "image/png", "image/gif" ] 
   validates_attachment_presence :archive

end
