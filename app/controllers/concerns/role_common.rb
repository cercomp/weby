module RoleCommon
  extend ActiveSupport::Concern

  def index
    @roles = @site ? @site.roles.order("id") : Role.where(:site_id => nil).order("id")
    @rights = Weby::Rights.permissions.sort
    
    if request.put? # && params[:role]
      params[:role] ||= {}
      @roles.each do |role| # params[:role].each do |role, right|
        role.update_attributes(permissions: params[:role][role.id.to_s] ? params[:role][role.id.to_s]['permissions'].to_s : "{}")
      end
      flash[:success] = t("successfully_updated")
      redirect_to @site ? site_admin_roles_path : admin_roles_path
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

end
