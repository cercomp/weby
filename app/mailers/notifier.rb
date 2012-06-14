# coding: utf-8
class Notifier < ActionMailer::Base
 def password_reset_instructions(user, host)
    default_url_options[:host] = host
    subject = "[Weby] Instruções de Recuperação de Senha"
    from = "web@cercomp.ufg.br"
    recipients = user.email  
    sent_on = Time.now
    @user = user
    @content = edit_admin_password_reset_url(user.perishable_token)
    mail(:from => from, :to => recipients, :subject => subject)
  end

  def activation_instructions(user, host)
    from = "web@cercomp.ufg.br"
    default_url_options[:host] = host
    subject = "[Weby] Ativação de conta"
    recipients = user.email_address_with_name
    @user = user
    @account_activation_url = activate_account_url(user.perishable_token)
    mail(:from => from, :to => recipients, :subject => subject)
  end

  def activation_confirmation(user, host)
    default_url_options[:host] = host
    subject = "[Weby] Conta ativada com sucesso!"
    from = "web@cercomp.ufg.br"
    recipients = user.email_address_with_name
    @user = user
    mail(:from => from, :to => recipients, :subject => subject)
  end
end
