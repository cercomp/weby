module Feedback
  class MessagesController < ApplicationController

    layout :choose_layout
    
    before_filter :get_groups, :only => [:new, :create]
    
    respond_to :html, :js

    def index
      @messages = Message.all
    end

    def new
      if(@groups.length == 0)
        users = User.by_site(current_site).actives
        redirect_to main_app.site_path(current_site),
                    :error => t('no_groups') and return if (users.length == 0)
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
          #FeedbackMailer.send_feedback(@message, emails, current_site).deliver
        else
          @message.groups.each do |group|
            #FeedbackMailer.send_feedback(@message, group.emails, current_site).deliver
          end
        end
        session[:feedback_id] = @message.id
        redirect_to sent_site_feedbacks_path
      else
        render :action => "new"
      end
    end

    def sent
      # Mostra mensagem de feedback enviado apenas uma vez
      unless session[:feedback_id].nil?
        @message = Message.find(session[:feedback_id])
        session.delete :feedback_id
      else
        # Se o usuário já viu a mensagem, ele é redirecionado para a página inicial do site
        redirect_to current_site
      end
    end

    private
    def get_groups
      @groups = current_site.groups
    end
  end
end
