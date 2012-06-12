class Sites::Admin::GroupsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    @groups = @site.groups.order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])

    if @groups.empty?
      flash[:warning] = (t"none_param", :param => t("group.one"))
    else
      flash[:warning] = t('group_explain')
    end
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
    @users = User.by_site(@site)
  end

  def edit
    @group = Group.find(params[:id])
    @users = User.by_site(@site)
  end

  def create
    @group = Group.new(params[:group])

    if @group.save
      redirect_to({:site_id => @group.site.name, :controller => 'groups'},
                  flash: {success: t('successfully_created')})
    else
      respond_with(:site_admin, @group)
    end
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      redirect_to({:site_id => @group.site.name, :controller => 'groups', :action => 'index'},
                  flash: {success: t('successfully_updated')})
    else
      redirect_to :back
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    redirect_to(site_admin_groups_url)
  end

  private
  def sort_column
    Group.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
