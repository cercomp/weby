class AdminController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization
  before_filter :load_images, :only => :edit

  respond_to :html, :xml, :js

  def index
  end

  def show
  end

  def edit
    @repository = Repository.new

    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] - Dir[File.join(Rails.root + "app/views/layouts/portal.html.erb")]).each do |file|
      @themes << file.split("/")[-1].split(".")[0]
    end
  end

  def update
  end

  def destroy
  end
end
