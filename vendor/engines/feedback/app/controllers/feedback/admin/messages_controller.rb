module Feedback::Admin
  class MessagesController < Feedback::ApplicationController
    before_filter :require_user
    before_filter :check_authorization
    respond_to :html, :xml, :js

    def index
      @messages = Feedback::Message.where(:site_id => current_site.id).order('id desc')
    end

    def show
      @message = Feedback::Message.find(params[:id])
    end

#    def edit
#      @message = Feedback::Message.find(params[:id])
#    end
#
#    def update
#      @message = Feedback::Message.find(params[:id])
#
#      if @message.update_attributes(params[:message])
#        redirect_to(message_path(@message),
#                    flash: {success: t("successfully_updated")})
#      else
#        render :action => "edit"
#      end
#    end

    def destroy
      @message = Feedback::Message.find(params[:id])
      @message.destroy

      redirect_to(admin_messages_path)
    end
  end
end
