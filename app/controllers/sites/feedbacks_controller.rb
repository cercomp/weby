class Sites::FeedbacksController < ApplicationController

  layout :choose_layout
  
  before_filter :get_groups, :only => [:new, :create]
  
  respond_to :html, :xml, :js

  def new
    if(@groups.length == 0)
      users = User.by_site(@site.id).actives
      if (users.length == 0)
        flash[:error] = t("no_groups")
        redirect_back_or_default @site
        return
      end
    end
    @feedback = Feedback.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  def create
    @feedback = Feedback.new(params[:feedback])

    if @feedback.save
      #Se não tiver nenhum grupo cadastrado no site, envia para todos os usuário do site
      if(@groups.length == 0)
        emails = User.by_site(@site.id).actives.map(&:email).join(',')
        FeedbackMailer.send_feedback(@feedback, emails, current_site).deliver
      else
        @feedback.groups.each do |group|
          FeedbackMailer.send_feedback(@feedback, group.emails, current_site).deliver
        end
      end
      session[:feedback_id] = @feedback.id
      redirect_to :action => 'sent'
    else
      render :action => "new"
    end
  end

  def sent
    # Mostra mensagem de feedback enviado apenas uma vez
    unless session[:feedback_id].nil?
      @feedback = Feedback.find(session[:feedback_id])
      session.delete :feedback_id
    else
      # Se o usuário já viu a mensagem, ele é redirecionado para a página inicial do site
      redirect_to [@site]
    end
  end

  private
  def get_groups
    @groups = Group.where(:site_id => @site.id)
  end
end
