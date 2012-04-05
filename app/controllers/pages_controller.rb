class PagesController < ApplicationController

  helper_method :sort_column

  respond_to :html, :js, :json

  # GET /pages
  # GET /pages.json
  def index
    @pages = @site.pages.
      includes(:translations, :author, :categories).
      page(params[:page]).per(params[:per_page]).
      order(sort_column + " " + sort_direction)
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = @site.pages.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = @site.pages.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = @site.pages.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = @site.pages.new(params[:page])
    @page.author = current_user

    respond_to do |format|
      if @page.save
        format.html { redirect_to [@site, @page], notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = @site.pages.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to [@site, @page], notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = @site.pages.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end

  private
  def sort_column
    params[:sort] || 'id'
  end
end
