require 'swagger_helper'

RSpec.describe 'api/v1/pages', type: :request do
  let(:locale) { FactoryBot.create(:locale) }
  let(:site) { FactoryBot.create(:site, locales: [locale]) }
  let(:user) { FactoryBot.create(:user) }
  let(:page_record) do
    p = Page.new(site_id: site.id, user_id: user.id, publish: true)
    p.i18ns.build(title: 'Page Title', text: 'Page text', locale_id: locale.id)
    p.save!
    p
  end
  let(:id_site) { site.id }
  let(:id) { page_record.id }
  let(:page_payload) do
    {
      site_id: site.id,
      user: user.id,
      publish: true,
      i18ns_attributes: [
        { title: 'Page Title', text: 'Page text', locale_id: locale.id }
      ]
    }
  end
  let(:page) { page_payload }

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
      parameter name: :page, in: :body, schema: {
        type: :object,
        properties: {
          site_id: { type: :integer, description: 'ID do site pertencente' },
          user: { type: :integer, description: 'ID do usuário criador do site' },
          publish: { type: :boolean, description: 'Define se a página será publicada' },
          i18ns_attributes: { 
            type: :array,
            items: {
              type: :object,
              properties: {
                title: { type: :string, description: 'Título do item de menu' },
                text: { type: :string, description: 'Texto da página' },
                description: { type: :string, description: 'Descrição do menu pertencente' },
                locale_id: { type: :integer, description: 'ID do idioma do site' }
              }
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
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show page') do
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

    patch('update page') do
      consumes 'application/json'
      parameter name: :page, in: :body, schema: {
        type: :object,
        properties: {
          site_id: { type: :integer, description: 'ID do site pertencente' },
          publish: { type: :boolean, description: 'Define se a página será publicada' }
        }
      }
      response(200, 'successful') do
        let(:page) { { site_id: site.id, publish: false } }

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
      parameter name: :page, in: :body, schema: {
        type: :object,
        properties: {
          site_id: { type: :integer, description: 'ID do site pertencente' },
          user: { type: :integer, description: 'ID do usuário criador do site' },
          i18ns_attributes: { 
            type: :array,
            items: {
              type: :object,
              properties: {
                id:{ type: :integer, description: 'ID do i18n' },
                title: { type: :string, description: 'Título do item de menu' },
                text: { type: :string, description: 'Texto da página' },
                description: { type: :string, description: 'Descrição do menu pertencente' },
                locale_id: { type: :integer, description: 'ID do idioma do site' }
              }
            }
          }
        },
        required: [ 'site_id', 'user', 'i18ns_attributes' ]
      }
      response(200, 'successful') do
        let(:page) do
          {
            site_id: site.id,
            user: user.id,
            i18ns_attributes: [
              { id: page_record.i18ns.first.id, title: 'Updated Page', text: 'Updated content', locale_id: locale.id }
            ]
          }
        end

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
