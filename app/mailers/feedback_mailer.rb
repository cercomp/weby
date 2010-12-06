class FeedbackMailer < ActionMailer::Base
  default :from => "nicolaslazartekaqui@gmail.com"

  def send_feedback feedback
    @feedback = feedback
    feedback.groups.each do |group|
      group.users.each do |user|
        mail :to => user.email, :subject => feedback.subject
      end
    end
  end

end
