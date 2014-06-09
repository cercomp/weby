module Feedback
  class MessagesController < Feedback::ApplicationController
    layout :choose_layout

    before_filter :get_groups, only: [:new, :create, :index]

    respond_to :html, :xml, :js

    def new
      @message = Message.new
    end

    def create
      @message = Message.new(params[:message])
      @message.site = current_site

      if @message.save
        if (@groups.length == 0)
          emails = User.no_admin.by_site(current_site.id).actives.map(&:email).join(',')
          FeedbackMailer.send_feedback(@message, emails, current_site).deliver
        else
          @message.groups.each do |group|
            FeedbackMailer.send_feedback(@message, group.emails, current_site).deliver
          end
        end
      else
        render action: 'new'
      end
    end

    private

    def get_groups
      @groups = Feedback::Group.where(site_id: current_site.id)
    end
  end
end
