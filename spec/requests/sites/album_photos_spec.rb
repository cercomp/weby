require 'rails_helper'

RSpec.describe 'Sites AlbumPhotos', type: :request do
  let!(:locale) { Locale.first || create(:locale, name: 'pt-BR') }
  let!(:site) { create(:site, name: 'photos-site', locales: [locale]) }
  let!(:user) { create(:user) }
  let(:test_image) { fixture_file_upload(Rails.root.join('app/assets/images/mime_list/photoshop.png'), 'image/png') }

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
    it 'renders album photo popup as JS successfully with 3d cube markup and manifest' do
      host! 'photos-site.lvh.me'
      get "/a/#{album.slug}/album_photos/#{photo.id}", xhr: true
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/javascript')
      expect(response.body).to include('photo-viewer-overlay')
      expect(response.body).to include('photo-viewer-content')
      expect(response.body).to include('photo-cube-stage')
      expect(response.body).to include('photo-cube-viewport')
      expect(response.body).to include('photo-cube-face')
      expect(response.body).to include('cube-face-shadow')
      expect(response.body).to include('album-photos-manifest')
      expect(response.body).to include('WEBY.initAlbumPhoto')
    end

    it 'returns 404 when album does not exist' do
      host! 'photos-site.lvh.me'
      get '/a/non-existent-album/album_photos/999999', xhr: true
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /a/:album_id (HTML & JSON)' do
    it 'renders album show page with full album manifest' do
      host! 'photos-site.lvh.me'
      get "/a/#{album.slug}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="album-all-photos-data"')
      expect(response.body).to include('modern-photos-grid')
    end

    it 'renders album json format with all photos manifest' do
      host! 'photos-site.lvh.me'
      get "/a/#{album.slug}.json"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['album_title']).to eq('Meu Album')
      expect(json['total_photos']).to eq(1)
      expect(json['photos']).to be_an(Array)
      expect(json['photos'].first['id']).to eq(photo.id)
    end
  end
end
