module Feedback::Admin
  class MessagesController < Feedback::ApplicationController
    before_action :require_user
    before_action :check_authorization

    respond_to :html, :xml, :js

    def index
      @messages = Feedback::Message.where(site_id: current_site.id)
        .order('id desc').name_or_subject_like(params[:search])
        .page(params[:page]).per(params[:per_page])
    end

    def show
      @message = Feedback::Message.find(params[:id])
    end

    def destroy
      @message = Feedback::Message.find(params[:id])
      @message.destroy

      redirect_to(admin_messages_path)
    end
  end
end
