module Feedback::Admin
  class MessagesController < Feedback::ApplicationController
    before_action :require_user
    before_action :check_authorization

    respond_to :html, :xml, :js

    def index
      @messages = current_site.messages
        .order('id desc').name_or_subject_like(params[:search])
        .page(params[:page]).per(params[:per_page])
    end

    def show
      @message = current_site.messages.find(params[:id])
      @message.update read_status: true
    end

    def destroy
      @message = current_site.messages.find(params[:id])
      @message.destroy

      redirect_to(admin_messages_path)
    end

    def destroy_many
      current_site.messages.where(id: params[:ids].split(',')).destroy_all

      redirect_back(fallback_location: admin_messages_path)
    end
  end
end
