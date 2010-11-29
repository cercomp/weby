class FeedbackMailer < ActionMailer::Base
  default :from => "from@example.com"

  def send(user)
    mail (:to => user.email,
          :subject => "Feedback to you")
  end
end
