require 'swagger_helper'

RSpec.describe 'api/v1/menus', type: :request do

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
