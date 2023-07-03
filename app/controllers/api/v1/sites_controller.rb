module API
  module V1
    class SitesController < BaseController
      before_action :authenticate_app
      #before_action :authenticate_api_user, except: [:index, :show]

      def index
        params[:page] ||= 1
        sites = Site.active.name_equal(params[:search])
        render json: sites.to_json(include: :active_skin), root: 'sites', meta: build_meta(sites)
      end

      def show
        site = Site.find_by id: params[:id]
        return not_found :site, params[:id] if !site
        render json: site.to_json(include: [:admin_users, :users], except: :theme), root: 'site'
      end

      def create
        site = Site.new(site_params)
        if create_site(site)
          Weby::Rights.seed_roles site.id
          
          render json: site, root: 'data'
        else
          render json: {error: t('api.site_not_created'), message: site.errors.full_messages}, status: 403
        end
      end

      def update
        site = Site.find(params[:id])
        if site.update_attributes(site_params)
          render json: site, root: 'data'
        else
          render json: {error: t('api.site_not_created'), message: @site.errors.full_messages}, status: 403
        end
      end

      def destroy
        site = Site.find_by id: params[:id]
        return not_found :site, params[:id] if !site
        
        begin
          site.unscoped_destroy!
          render json: {msg: t('successfully_deleted')}, status: 200
        rescue ActiveRecord::RecordNotDestroyed => error
          render json: {error: t('api.error_destroying_object'), message: @site.errors.full_messages}, status: 400
        end
      end

      private

      def create_site site
        ActiveRecord::Base.transaction do
          # Validations
          site.errors.add(:base, 'Nenhum gestor informado') && raise(ActiveRecord::Rollback) if params[:managers].blank?
          managers = User.where(id: params[:managers])
          site.errors.add(:base, 'Gestor não encontrado')   && raise(ActiveRecord::Rollback) if managers.blank?
          site.errors.add(:base, 'Nenhum tema informado')   && raise(ActiveRecord::Rollback) if params[:theme].blank?
          theme = ::Weby::Themes.theme(params[:theme])
          site.errors.add(:base, 'Tema não encontrado')     && raise(ActiveRecord::Rollback) if theme.blank?
          #site.errors.add(:base, t('only_admin'))           && raise(ActiveRecord::Rollback) if theme.is_private
          #
          site.save!
          # Assign site admins
          admin_role = site.find_or_create_local_admin_role!
          managers.each do |user|
            user.roles << admin_role
          end
          # Assign theme
          skin = site.skins.create!(name: theme.name.titleize, theme: theme.name, active: true)
          theme.populate skin, user: managers.first
        end
      rescue ActiveRecord::RecordInvalid
        false
      end

      def site_params
        params.require(:site).permit(:title, :top_banner_id, :name, :parent_id,
          :domain, :description, :show_pages_author,
          :show_pages_created_at, :show_pages_updated_at,
          :restrict_theme, :body_width, :google_analytics,
          :per_page, :per_page_default, :status, 
          {locale_ids: [], grouping_ids: []})
      end
    end
  end
end
