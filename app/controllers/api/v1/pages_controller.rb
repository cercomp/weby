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

      def show
        @page = Page.find_by id: params[:id]
        return not_found :page, params[:id] if !@page
        render json: @page.to_json(include: :i18ns), root: 'page'
      end

      def create
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
          @page.user = user

          page.save!
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      # PUT /pages/1
      # PUT /pages/1.json
      def update
        @page = Page.find_by id: params[:id]
        puts page_params
        if @page.update(page_params)
          render json: @page, root: 'data'
        else
          render json: {error: t('api.page_not_created'), message: @page.errors.full_messages}, status: 403
        end
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
