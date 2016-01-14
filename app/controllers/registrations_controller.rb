class RegistrationsController < Devise::RegistrationsController
  def create
    if simple_captcha_valid?
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      @captcha_errors = t("simple_captcha.captcha_code")
      render :new
    end
  end
end