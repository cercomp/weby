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

  included do
    before_action :load_object_for_toggle, only: [:toggle]
  end

  # PUT /toggle?field=FIELD_NAME
  def toggle
    result = toggle_attribute!
    message = [:success, t('successfully_updated')]
    if !result
      message = [:warning, t('error_updating_object')]
    end

    respond_to do |format|
      format.json do
        status = @object.send(params[:field])
        render json: {
          ok: result,
          message: message[1],
          icon: ActionController::Base.helpers.asset_url("#{result ? 'true' : 'false'}.png"),
          status: status,
          title: status ? t('enable') : t('disable')
        }
      rescue
        render status: 500, json: {
          ok: false,
          message: t('error_updating_object'),
          icon: ActionController::Base.helpers.asset_url("false.png"),
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

  private

  def load_object_for_toggle
    @object = resource_for_toggle
  end

  def resource_for_toggle
    resource
  end

  # metodo que faz toggle do atributo, por padrão é considerado
  # que o atributo será um booleano, desse modo apenas é mudado
  # o valor do campo "true -> false"
  #
  # caso seja necessário trabalhar com outros tipos de campos
  # esse método pode ser sobreecrito, observando que sempre deve
  # retornar true ou false
  def toggle_attribute!
    return false if @object.blank? && params[:field].blank?

    if @object.respond_to?("#{params[:field]}?")
      @object.toggle!(params[:field])
    elsif @object.respond_to?("toggle_#{params[:field]}")
      @object.send("toggle_#{params[:field]}".to_sym)
    end
  end

  # path que será redirecionando após a action toggle
  # por default é :back
  def after_toggle_path
    request.env['HTTP_REFERER']
  end

end
