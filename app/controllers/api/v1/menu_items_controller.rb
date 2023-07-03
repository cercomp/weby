module API
  module V1
    class MenuItemsController < BaseController
      before_action :authenticate_app

      def index
        params[:page] ||= 1
        menu = Menu.find_by id: params[:id]
        return not_found :menu, params[:id] if !menu

        @menu_items = menu.menu_items
        render json: @menu_items
      end

      def create
        @menu_item = MenuItem.new(menu_items_params)
        puts @menu_item
        if create_menu_items(@menu_item)
          render json: @menu_item, root: 'data'
        else
          render json: {error: t('api.menu_items_not_created'), message: @menu_item.errors.full_messages}, status: 403
        end
      end

      def update
        params[:page] ||= 1
        @menu_item = MenuItem.find_by id: params[:id]
        return not_found :menu_item, params[:id] if !@menu_item

        if @menu_item.update(menu_items_params)
          render json: @menu_item, root: 'data'
        else
          render json: {error: t('api.menu_items_not_updated'), message: @menu_item.errors.full_messages}, status: 403
        end
      end

      def create_menu_items menu_item
        ActiveRecord::Base.transaction do
          # Validations
          
          menu_item.save!
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      def menu_items_params
        params.require(:menu_item).permit(:url, :menu_id, :target_id, :parent_id, :target_type, :new_tab,
          :publish, :html_class, { i18ns_attributes: [:id, :locale_id, :title, :description] })
      end
    end
  end
end
