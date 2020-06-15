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
    result = toggle_attribute!
    message = [:success, t('successfully_updated')]
    if !result
      message = [:warning, t('error_updating_object')]
    end

    respond_with do |format|
      format.js do
        status = resource.send(params[:field])
        render json: {
          ok: result,
          message: message[1],
          icon: ActionController::Base.helpers.asset_url("#{result ? 'true' : 'false'}.png"),
          status: status,
          title: status ? t('enable') : t('disable')
        }
      end
      format.html do
        flash[message[0]] = message[1]
        redirect_to after_toggle_path
      end
    end
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
