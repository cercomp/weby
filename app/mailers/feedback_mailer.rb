class FeedbackMailer < ActionMailer::Base
  default :from => "web@cercomp.ufg.br"

  def send_feedback feedback
    @feedback = feedback
    feedback.groups.each do |group|
      mail :to => group.emails, :subject => @feedback.subject
    end
  end

end
