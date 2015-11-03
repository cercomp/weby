module Feedback
  class FeedbackMailer < ActionMailer::Base
    def send_feedback(feedback, destination, site)
      @feedback = feedback
      @site_title = site.title
      mail(from: ActionMailer::Base.smtp_settings[:user_name] || feedback.email,
           reply_to: feedback.email, to: destination, cc: feedback.email, subject: feedback.subject)
    end
  end
end
