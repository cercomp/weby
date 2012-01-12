class FeedbackMailer < ActionMailer::Base

  def send_feedback (feedback,destination)
    @feedback = feedback
    mail :from => feedback.email, :to => destination, :subject => feedback.subject
  end

end
