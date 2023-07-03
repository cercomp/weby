require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do

  path '/api/v1/users/find' do

    get('find user') do
      parameter name: :email, in: :query, type: :string, description: 'E-mail do usuário'
      parameter name: :login, in: :query, type: :string, description: 'Login do usuário'
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
