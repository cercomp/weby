require 'rails_helper'

RSpec.describe 'Sites AlbumPhotos', type: :request do
  let!(:locale) { Locale.first || create(:locale, name: 'pt-BR') }
  let!(:site) { create(:site, name: 'photos-site', locales: [locale]) }
  let!(:user) { create(:user) }
  let(:test_image) { File.open(Rails.root.join('app/assets/images/mime_list/photoshop.png')) }

  let!(:album) do
    alb = Album.new(
      site: site,
      user: user,
      publish: true,
      slug: 'meu-album',
      skip_photos_limit_validation: true,
      i18ns_attributes: [{ locale_id: locale.id, title: 'Meu Album' }]
    )
    alb.save(validate: false)
    alb.album_photos.create!(image: test_image, user: user, is_cover: true, position: 1)
    alb
  end

  let!(:photo) { album.album_photos.first }

  describe 'GET /a/:album_id/album_photos/:id (JS)' do
    it 'renders album photo popup as JS successfully' do
      host! 'photos-site.lvh.me'
      get "/a/#{album.slug}/album_photos/#{photo.id}", xhr: true
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/javascript')
      expect(response.body).to include('photo-viewer-overlay')
      expect(response.body).to include('photo-viewer-content')
    end

    it 'returns 404 when album does not exist' do
      host! 'photos-site.lvh.me'
      get '/a/non-existent-album/album_photos/999999', xhr: true
      expect(response).to have_http_status(:not_found)
    end
  end
end
