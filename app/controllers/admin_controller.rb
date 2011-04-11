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
    @repository = Repository.new
    @repositories = @site.repositories.where("archive_content_type LIKE '%#{params[:search]}%'").
      and("description LIKE '%#{params[:type]}%'").
      order('id DESC').page(params[:page]).per(params[:per_page])

    @themes = []
    Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")].each do |file|
      @themes << file.split("/")[-1].split(".")[0]
    end

    if @repositories.empty?
      flash.now[:warning] = (t"none_param", :param => t("picture"))
    end
    respond_with do |format|
      format.js { 
        render :update do |page|
        page.call "$('#form').html",
          render(:partial => 'form',
                 :locals => { :f => SemanticFormBuilder.new(:site,
                                                            @site,
                                                            self,
                                                            {},
                                                            proc{}) })
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
