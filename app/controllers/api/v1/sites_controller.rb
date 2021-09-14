module API
  module V1
    class SitesController < BaseController
      before_action :authenticate_app
      #before_action :authenticate_api_user, except: [:index, :show]

      def index
        params[:page] ||= 1
        sites = Site.active.name_or_description_like(params[:search])
        render json: sites, root: 'sites', meta: build_meta(sites)
      end

      def show
        site = Site.find_by id: params[:id]
        return not_found :site, params[:id] if !site
        render json: site, root: 'site'
      end

      def create
        site = Site.new(site_params)
        if create_site(site)
          Weby::Rights.seed_roles site.id
          
          render json: site, root: :site
        else
          render json: {error: t('api.site_not_created'), message: site.errors.full_messages}, status: 403
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
          site.errors.add(:base, t('only_admin'))           && raise(ActiveRecord::Rollback) if theme.is_private
          #
          site.save!
          # Assign site admins
          admin_role = site.find_or_create_local_admin_role!
          managers.each do |user|
            user.roles << admin_role
          end
          # Assign theme
          skin = site.skins.create!(name: theme.name.titleize, theme: theme.name, active: true)
          record_activity('theme_installed', skin)
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
