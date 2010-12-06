class FeedbackMailer < ActionMailer::Base
  default :from => "web@cercomp.ufg.br"

  def send_email feedback
    feedback.groups.each do |group|
      group.users.each do |user|
        logger.debug "enviando email para >>>>> " + user.email
        mail :to => user.email, :subject => feedback.subject
      end
    end
  end

end
