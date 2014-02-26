module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      puts options
      if crop_command and options[:geometry] == 'original'
        r = super
        if r.class == Array
          r = r.join(' ')
        end
        crop_command + r.sub(/ -crop \S+/, '')
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if target.cropping?
       ["-crop","#{target.w.to_i}x#{target.h.to_i}+#{target.x.to_i}+#{target.y.to_i} "].join(' ')
      end
    end
  end
end