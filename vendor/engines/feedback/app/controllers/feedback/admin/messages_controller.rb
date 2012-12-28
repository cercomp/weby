module Feedback::Admin
  class MessagesController < Feedback::ApplicationController
    before_filter :require_user
    before_filter :check_authorization
    respond_to :html, :xml, :js

    def index
      @messages = Feedback::Message.where(:site_id => current_site.id).order('id desc')
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @messages }
      end
    end

    def show
      @message = Feedback::Message.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @message }
      end
    end

    def destroy
      @message = Feedback::Message.find(params[:id])
      @message.destroy

      respond_to do |format|
        format.html { redirect_to(admin_messages_path) }
        format.xml  { head :ok }
      end
    end

  end
end
