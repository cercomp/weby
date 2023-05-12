require 'swagger_helper'

RSpec.describe 'api/v1/pages', type: :request do

  path '/api/v1/pages' do

    get('Lista paginas de um site') do
      parameter name: :id_site, in: :query, type: :integer, description: 'ID do site'
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

    post('Cria página') do
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          site_id: { type: :integer, description: 'ID do site pertencente' },
          user: { type: :boolean, description: 'ID do usuário criador do site' },
          i18ns_attributes: { 
            type: :object, 
            properties: {
              title: { type: :string, description: 'Título do item de menu' },
              description: { type: :string, description: 'Descrição do menu pertencente' },
              locale_id: { type: :integer, description: 'ID do idioma do site' }
            }
          }
        },
        required: [ 'site_id', 'user', 'i18ns_attributes' ]
      }
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

  path '/api/v1/pages/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show page') do
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

    patch('update page') do
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

    put('Atualiza pagina') do
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          site_id: { type: :integer, description: 'ID do site pertencente' },
          user: { type: :boolean, description: 'ID do usuário criador do site' },
          i18ns_attributes: { 
            type: :object, 
            properties: {
              title: { type: :string, description: 'Título do item de menu' },
              description: { type: :string, description: 'Descrição do menu pertencente' },
              locale_id: { type: :integer, description: 'ID do idioma do site' }
            }
          }
        },
        required: [ 'site_id', 'user', 'i18ns_attributes' ]
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
