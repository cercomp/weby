require 'rails_helper'

RSpec.describe AlbumPhoto, type: :model do
  describe 'validates_attachment_size with Paperclip on Rails 8' do
    it 'validates attachment size without raising uninitialized constant CHECKS' do
      test_image = File.open(Rails.root.join('app/assets/images/mime_list/photoshop.png'))
      photo = AlbumPhoto.new(image: test_image)

      expect { photo.valid? }.not_to raise_error
      expect(photo.errors[:image]).not_to include('AttachmentSizeValidator')
    end
  end
end
