class FeedbackMailer < ActionMailer::Base

  def send_feedback feedback,destination=nil
    @feedback = feedback
    if(destination)
      create_feedback_mail(feedback, destination).deliver
    else
      feedback.groups.each do |group|
        create_feedback_mail(feedback, group.emails).deliver
      end
    end
  end

  private
  def create_feedback_mail feedback, destination
    mail :from => feedback.email, :to => destination, :subject => feedback.subject
  end
end
