# coding: utf-8
class Notifier < ActionMailer::Base

 def password_reset_instructions(user, host)
    default_url_options[:host] = host
    subject = "Weby - Instruções de Recuperação de Senha"
    from = "web@cercomp.ufg.br"
    recipients = user.email  
    sent_on = Time.now
    @user = user
    @content = edit_password_reset_url(user.perishable_token)
    mail(:from => from, :to => recipients, :subject => subject)
  end    
end
