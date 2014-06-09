# Concern that creates the toggle actions in a controller
# Just add to your controller to use:
#
#   include ActsToToggle
#
# and add  the new route:
# eg.
#
#   resource :users do
#     member do
#       put :toggle
#     end
#   end
module ActsToToggle
  extend ActiveSupport::Concern

  # PUT /toggle?field=FIELD_NAME
  def toggle
    if toggle_attribute!
      flash[:success] = t('successfully_updated')
    else
      flash[:warning] = t('error_updating_object')
    end

    redirect_to after_toggle_path
  end

  # metodo que faz toggle do atributo, por padrão é considerado
  # que o atributo será um booleano, desse modo apenas é mudado
  # o valor do campo "true -> false"
  #
  # caso seja necessário trabalhar com outros tipos de campos
  # esse método pode ser sobreecrito, observando que sempre deve
  # retornar true ou false
  def toggle_attribute!
    return false if resource.blank? && params[:field].blank?

    resource.toggle!(params[:field])
  end

  # path que será redirecionando após a action toggle
  # por default é :back
  def after_toggle_path
    request.env['HTTP_REFERER']
  end

  private :toggle_attribute!, :after_toggle_path
end
