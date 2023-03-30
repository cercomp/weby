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

      def create_menu_items menu_item
        ActiveRecord::Base.transaction do
          # Validations
          #site.errors.add(:base, 'Nenhum gestor informado') && raise(ActiveRecord::Rollback) if params[:managers].blank?
          #managers = User.where(id: params[:managers])
          #site.errors.add(:base, 'Gestor não encontrado')   && raise(ActiveRecord::Rollback) if managers.blank?
          #site.errors.add(:base, 'Nenhum tema informado')   && raise(ActiveRecord::Rollback) if params[:theme].blank?
          #theme = ::Weby::Themes.theme(params[:theme])
          #site.errors.add(:base, 'Tema não encontrado')     && raise(ActiveRecord::Rollback) if theme.blank?
          #site.errors.add(:base, t('only_admin'))           && raise(ActiveRecord::Rollback) if theme.is_private
          #
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
