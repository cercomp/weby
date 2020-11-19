module Feedback
  class MessagesController < Feedback::ApplicationController
    layout :choose_layout

    before_action :get_groups, only: [:new, :create]

    respond_to :html

    def new
      @message = Message.new(name: t('.feedback'))
      @extension = current_site.extensions.find_by(name: 'feedback')
    end

    def create
      @message = Message.new(message_params)
      @message.site = current_site
      @extension = current_site.extensions.find_by(name: 'feedback')

      if simple_captcha_valid?
        if @message.save
          if (@groups.length == 0)
            emails = current_site.users.no_admin.actives.map(&:email).join(',')
            FeedbackMailer.send_feedback(@message, emails, current_site).deliver_now
          else
            @message.groups.each do |group|
              emails = group.emails_array.join(',')
              FeedbackMailer.send_feedback(@message, group.emails, current_site).deliver_now
            end
          end
        else
          render 'new'
        end
      else
        @captcha_errors = t('simple_captcha.captcha_code')
        render 'new'
      end
    end

    private

    def get_groups
      @groups = current_site.groups.order(position: :asc)
    end

    def message_params
      params.require(:message).permit(:name, :email, :subject, :message, :site_id, { group_ids: [] })
    end
  end
end
