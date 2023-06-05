require 'swagger_helper'

RSpec.describe 'api/v1/components', type: :request do

  path '/api/v1/components' do

    get('Lista de componente de um site') do
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
  path '/api/v1/components/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('Atualiza componente') do
      consumes 'application/json'
      parameter name: :component, in: :body, schema: {
        type: :object,
        properties: {
          publish: { type: :boolean, description: 'ID do componente' }
        },
        required: [ 'publish' ]
      }
      response(200, 'successful') do
        let(:id) { '123' }

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
