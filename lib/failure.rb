class Failure < Devise::FailureApp
  def redirect_url
    if warden_message == :unconfirmed
      login_path
    else
      super
    end
  end
end
