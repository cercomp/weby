require 'swagger_helper'

RSpec.describe 'api/v1/menu_items', type: :request do
  let(:locale) { FactoryBot.create(:locale) }
  let(:site) { FactoryBot.create(:site, locales: [locale]) }
  let(:menu) { FactoryBot.create(:menu, site_id: site.id) }
  let(:item) { FactoryBot.create(:menu_item, menu_id: menu.id, i18ns_attributes: [{ title: 'Item', locale_id: locale.id }]) }
  let(:id) { menu.id }
  let(:menu_item) do
    {
      menu_id: menu.id,
      publish: true,
      parent_id: nil,
      url: 'http://example.com',
      i18ns_attributes: [{ title: 'Item', locale_id: locale.id }]
    }
  end

  path '/api/v1/menu_items' do

    get('Lista de items de menu') do
      parameter name: :id, in: :query, type: :integer, description: 'ID do menu a qual pertence'
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

    post('Cria menu item') do
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          menu_id: { type: :integer, description: 'ID do menu pertencente' },
          new_tab: { type: :boolean, description: 'Campo para abrir a url do item de menu em uma nova aba' },
          publish: { type: :boolean, description: 'Campo para publicar o item de menu' },
          parent_id: { type: :integer, description: 'ID do item de menu pai (Se houver)' },
          url: { type: :string, description: 'URL do item de menu' },
          i18ns_attributes: { 
            type: :array,
            items: {
              type: :object,
              properties: {
                title: { type: :string, description: 'Título do item de menu' },
                description: { type: :string, description: 'Descrição do menu pertencente' },
                locale_id: { type: :integer, description: 'ID do idioma do site' }
              }
            }
          }
        },
        required: [ 'publish', 'parent_id', 'url' ]
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

  path '/api/v1/menu_items/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    patch('Atualiza item de menu por atributo do objeto') do
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          publish: { type: :boolean, description: 'Campo para publicar o item de menu' }
        },
        required: [ 'publish' ]
      }
      response(200, 'successful') do
        let(:id) { item.id }
        let(:menu_item) { { publish: false } }

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

    put('Atualiza item de menu pelo objeto') do
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          menu_id: { type: :integer, description: 'ID do menu pertencente' },
          new_tab: { type: :boolean, description: 'Campo para abrir a url do item de menu em uma nova aba' },
          publish: { type: :boolean, description: 'Campo para publicar o item de menu' },
          parent_id: { type: :integer, description: 'ID do item de menu pai (Se houver)' },
          url: { type: :string, description: 'URL do item de menu' },
          i18ns_attributes: { 
            type: :array, 
            items: {
              type: :object,
              properties: {
                id: { type: :integer, description: 'ID do i18n' },
                title: { type: :string, description: 'Título do item de menu' },
                description: { type: :string, description: 'Descrição do menu pertencente' },
                locale_id: { type: :integer, description: 'ID do idioma do site' }
              }
            }
          }
        },
        required: [ 'publish', 'parent_id', 'url' ]
      }
      response(200, 'successful') do
        let(:id) { item.id }
        let(:menu_item) do
          {
            menu_id: menu.id,
            publish: true,
            parent_id: nil,
            url: 'http://example.com',
            i18ns_attributes: [{ id: item.i18ns.first.id, title: 'Updated Item', locale_id: locale.id }]
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
