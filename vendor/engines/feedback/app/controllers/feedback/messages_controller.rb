module Feedback
  class MessagesController < Feedback::ApplicationController
    layout :choose_layout
    before_filter :get_groups, only: [:new, :create, :index]

    respond_to :html, :js

    def new
      if(@groups.length == 0)
        users = User.by_site(current_site).actives
        redirect_to main_app.site_path(subdomain: current_site),
          error: t('no_groups') and return if (users.length == 0)
      end
      @message = Message.new

      respond_with @message
    end

    def create
      @message = Message.new(params[:message])
      @message.site = current_site

      if @message.save
        #Se não tiver nenhum grupo cadastrado no site, envia para todos os usuário do site
        if(@groups.length == 0)
          emails = User.by_site(current_site.id).actives.map(&:email).join(',')
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
