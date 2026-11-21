require 'swagger_helper'

RSpec.describe 'api/v1/menus', type: :request do
  let(:locale) { FactoryBot.create(:locale) }
  let(:site) { FactoryBot.create(:site, locales: [locale]) }
  let(:id) { site.id }

  path '/api/v1/menus' do

    get('Lista de menus') do
      parameter name: :id, in: :query, type: :integer, description: 'ID do site'
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
