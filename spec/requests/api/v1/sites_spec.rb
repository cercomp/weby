require 'swagger_helper'

RSpec.describe 'api/v1/sites', type: :request do
  let(:locale) { FactoryBot.create(:locale) }
  let(:user) { FactoryBot.create(:user) }
  let(:site_record) { FactoryBot.create(:site, locales: [locale]) }
  let(:id) { site_record.id }
  let(:search) { site_record.name }
  let(:site_post) do
    {
      managers: [user.id],
      theme: 'weby',
      site: {
        name: "site#{rand(1000..9999)}",
        title: 'New Site',
        locale_ids: [locale.id]
      }
    }
  end
  let(:site_put) do
    {
      site_id: site_record.id,
      managers: [user.id],
      theme: 'weby',
      site: {
        title: 'Updated Site'
      }
    }
  end

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
        let(:site) { site_post }

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
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show site') do
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

    patch('update site') do
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
        let(:site) { site_put }

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
        let(:site) { site_put }

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
