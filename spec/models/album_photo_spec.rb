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

  describe '#next_photo and #prev_photo navigation' do
    let!(:locale) { Locale.first || create(:locale, name: 'pt-BR') }
    let!(:site) { create(:site, name: 'photospecsite', locales: [locale]) }
    let!(:user) { create(:user) }
    let(:image1) { File.open(Rails.root.join('app/assets/images/mime_list/png.png')) }
    let(:image2) { File.open(Rails.root.join('app/assets/images/mime_list/bmp.png')) }
    let(:image3) { File.open(Rails.root.join('app/assets/images/mime_list/gif.png')) }

    it 'navigates reliably between photos using position and id' do
      album = Album.new(
        site: site,
        user: user,
        publish: true,
        slug: 'album-teste',
        skip_photos_limit_validation: true,
        i18ns_attributes: [{ locale_id: locale.id, title: 'Album de Teste' }]
      )
      album.save(validate: false)

      photo1 = album.album_photos.create!(image: image1, user: user, position: 1, is_cover: true)
      photo2 = album.album_photos.create!(image: image2, user: user, position: 2)
      photo3 = album.album_photos.create!(image: image3, user: user, position: 2)

      expect(photo1.next_photo).to eq(photo2)
      expect(photo2.next_photo).to eq(photo3)
      expect(photo3.next_photo).to be_nil

      expect(photo3.prev_photo).to eq(photo2)
      expect(photo2.prev_photo).to eq(photo1)
      expect(photo1.prev_photo).to be_nil
    end
  end
end
