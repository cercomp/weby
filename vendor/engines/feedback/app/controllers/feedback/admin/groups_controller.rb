module Feedback::Admin
  class GroupsController < Feedback::ApplicationController
    before_action :require_user
    before_action :check_authorization

    respond_to :html, :js

    helper_method :sort_column

    def index
      @groups = current_site.groups
        .order(sort_column + ' ' + sort_direction)
        .page(params[:page]).per(params[:per_page])
    end

    def show
      @group = current_site.groups.find(params[:id])
    end

    def new
      @group = current_site.groups.new
    end

    def edit
      @group = current_site.groups.find(params[:id])
    end

    def create
      @group = current_site.groups.new(group_params)

      if @group.save
        redirect_to({ site_id: @group.site.name, controller: 'groups' },
                    flash: { success: t('successfully_created') })
      else
        respond_with(:site_admin, @group)
      end
    end

    def update
      @group = current_site.groups.find(params[:id])
      if @group.update(group_params)
        redirect_to({ site_id: @group.site.name, controller: 'groups', action: 'index' },
                    flash: { success: t('successfully_updated') })
      else
        respond_with(:site_admin, @group)
      end
    end

    def destroy
      @group = current_site.groups.find(params[:id])
      @group.destroy

      redirect_to(admin_groups_url)
    end

    def destroy_many
      current_site.groups.where(id: params[:ids].split(',')).destroy_all

      redirect_back(fallback_location: admin_groups_url)
    end

    private

    def sort_column
      Feedback::Group.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def group_params
      params.require(:group).permit(:name, :emails)
    end
  end
end
