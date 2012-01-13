class FeedbacksController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :except => [:new, :create, :sent, :get_groups]
  before_filter :check_authorization, :except => [:new, :create, :sent, :get_groups]
  before_filter :get_groups, :only => [:new, :edit, :create, :update]
  respond_to :html, :xml, :js

  def index
    @feedbacks = Feedback.where(:site_id => @site.id)
    #Group.find(:all, :select => 'name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedbacks }
    end
  end

  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

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

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def create
    @feedback = Feedback.new(params[:feedback])

    if @feedback.save
      #Se não tiver nenhum grupo cadastrado no site, envia para todos os usuário do site
      if(@groups.length == 0)
        emails = User.by_site(@site.id).actives.map(&:email).join(',')
        FeedbackMailer.send_feedback(@feedback, emails).deliver
      else
        @feedback.groups.each do |group|
          FeedbackMailer.send_feedback(@feedback,group.emails).deliver
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

  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        format.html { redirect_to(site_feedback_url,
                      :notice => t("successfully_updated")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to(site_feedbacks_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def get_groups
    @groups = Group.where(:site_id => @site.id)
  end
end
