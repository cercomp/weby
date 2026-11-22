require 'rails_helper'

RSpec.describe 'Feeds and Sitemaps', type: :request do
  let!(:locale) { Locale.first || create(:locale, name: 'pt-BR') }
  let!(:site) { create(:site, name: 'portalsite', locales: [locale]) }
  let!(:user) { create(:user) }

  before do
    site.extensions.create!(name: 'journal')
  end

  describe 'GET /sitemap.xml' do
    it 'returns 404 for nonexistent site' do
      host! 'invalidsite.lvh.me'
      get '/sitemap.xml'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 200 and valid XML for an existing site' do
      host! 'portalsite.lvh.me'
      get '/sitemap.xml'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('xml')
    end
  end

  describe 'GET /feed' do
    it 'returns 200 and renders RFC822 pubDate without wrong number of arguments error' do
      news = Journal::News.create!(
        site: site,
        user_id: user.id,
        status: 'published',
        created_at: 1.day.ago,
        i18ns_attributes: [{ locale_id: locale.id, title: 'Noticia RSS', text: 'Texto RSS' }]
      )
      site.news_sites.create!(journal_news_id: news.id)

      host! 'portalsite.lvh.me'
      get '/feed'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<pubDate>')
      expect(response.body).to include(news.created_at.to_fs(:rfc822))
    end
  end
end
