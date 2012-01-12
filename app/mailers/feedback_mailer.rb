class FeedbackMailer < ActionMailer::Base

  def create_send_feedback feedback, destination=nil
    if(destination)
      send_feedback(feedback, destination).deliver
    else
      feedback.groups.each do |group|
        send_feedback(feedback, group.emails).deliver
      end
    end
  end

  def send_feedback feedback, destination
    @feedback = feedback
    mail :from => feedback.email, :to => destination, :subject => feedback.subject
  end

end
