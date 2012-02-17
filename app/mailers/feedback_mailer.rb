class FeedbackMailer < ActionMailer::Base

  def send_feedback (feedback,destination)
    @feedback = feedback
    from = "web@cercomp.ufg.br"
    mail(:from => from, :to => destination, :subject => feedback.subject)
  end

end
