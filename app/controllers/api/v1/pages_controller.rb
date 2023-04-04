module API
  module V1
    class PagesController < BaseController
      before_action :authenticate_app

      def index
        @site = get_site
        @pages = @site.pages
        
        return not_found :site, params[:id] if !@pages
        render json: @pages
      end

      def create
        #puts page_params[:site_id]
        #@site = Site.find_by id: page_params[:site_id]
        #return not_found :site, params[:site_id] if !@site

        @page = Page.new(page_params)

        if create_page(@page)          
          render json: @page, root: 'data'
        else
          render json: {error: t('api.page_not_created'), message: @page.errors.full_messages}, status: 403
        end
      end

      def create_page page
        ActiveRecord::Base.transaction do
          # Validations
          page.errors.add(:base, 'Nenhum usuario informado') && raise(ActiveRecord::Rollback) if params[:user].blank?
          user = User.find_by(id: params[:user])
          #site.errors.add(:base, 'Nenhum gestor informado') && raise(ActiveRecord::Rollback) if params[:managers].blank?
          #managers = User.where(id: params[:managers])
          #site.errors.add(:base, 'Gestor não encontrado')   && raise(ActiveRecord::Rollback) if managers.blank?
          #site.errors.add(:base, 'Nenhum tema informado')   && raise(ActiveRecord::Rollback) if params[:theme].blank?
          #theme = ::Weby::Themes.theme(params[:theme])
          #site.errors.add(:base, 'Tema não encontrado')     && raise(ActiveRecord::Rollback) if theme.blank?
          #site.errors.add(:base, t('only_admin'))           && raise(ActiveRecord::Rollback) if theme.is_private
          #
          puts user
          @page.user = user
          page.save!
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      def get_site
        @site = Site.find_by id: params[:id_site]
        return not_found :site, params[:id_site] if !@site

        @site
      end

      private

      def page_params
        params.require(:page).permit(:site_id, :publish, :slug, :text_type,
                                     { i18ns_attributes: [:id, :locale_id, :title, :text, :_destroy],
                                     related_file_ids: [] })
      end
      
    end
  end
end
