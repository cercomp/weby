class AdminController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js

  def index
  end

  def show
  end

  def edit
    params[:type] ||= 'image'

    @repositories = @site.repositories.search(params[:search], params[:page], params[:type])
    if @repositories.empty?
      flash.now[:warning] = (t"none_param", :param => t("picture"))
    end
    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#form').html", render(:partial => 'form', :locals => { :f => SemanticFormBuilder.new(:site, @site, self, {}, proc{}) })
          #page.replace_html 'form', :partial => 'form'
        end
      }
      format.html
    end
  end

  def update
  end

  def destroy
  end
end
