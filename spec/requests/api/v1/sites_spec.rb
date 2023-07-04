require 'swagger_helper'

RSpec.describe 'api/v1/sites', type: :request do

  path '/api/v1/sites' do

    get('Lista de sites') do
      parameter name: :search, in: :query, type: :string, description: 'Nome do site'
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

    post('Cria site') do
      consumes 'application/json'
      parameter name: :site, in: :body, schema: {
        type: :object,
        properties: {
          managers: { type: :array, items: {type: :integer}, description: 'IDs dos gerenciadores do site' },
          theme: { type: :string, description: 'Nome do tema' },
          site: {
            type: :object,
            properties: {
              name: { type: :string, description: 'Nome do site' },
              title: { type: :string, description: 'Título do site' },
              locale_id: { type: :array, items: {type: :integer}, description: 'ID do idioma do site' },
              parent_id: { type: :integer, description: 'ID do site pai' },
            }
          }
        },
        required: [ 'managers', 'theme' ]
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

  path '/api/v1/sites/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show site') do
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

    patch('update site') do
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

    put('Atualiza site') do
      consumes 'application/json'
      parameter name: :site, in: :body, schema: {
        type: :object,
        properties: {
          site_id: { type: :integer, description: 'ID do site' },
          managers: { type: :array, items: {type: :integer},  description: 'IDs dos gerenciadores do site' },
          theme: { type: :string, description: 'Nome do tema' }
        },
        required: [ 'managers', 'theme' ]
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

    delete('deleta site') do
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
