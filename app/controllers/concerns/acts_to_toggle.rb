module ActsToToggle
  extend ActiveSupport::Concern

  def toggle
    if params[:field] && resource 
      if resource.toggle!(params[:field])
        flash[:success] = t("successfully_updated")
      else
        flash[:warning] = t("error_updating_object")
      end
    end

    redirect_to after_toggle_path
  end

  # TODO separar em outro concern as ações do resource
  def resource
    get_resource_ivar || set_resource_ivar(self.controller_name.classify.constantize.send(:find, params[:id]))
  end

  def get_resource_ivar
    instance_variable_get("@#{self.controller_name.singularize}")
  end

  def set_resource_ivar(resource)
    instance_variable_set("@#{self.controller_name.singularize}", resource)
  end

  def after_toggle_path
    request.env["HTTP_REFERER"]
  end

  private :resource, :get_resource_ivar, :set_resource_ivar, :after_toggle_path
end
