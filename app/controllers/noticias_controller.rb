class NoticiasController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    @noticias = Noticia.all
    respond_with(@noticias)
  end

  def show
    @noticia = Noticia.find(params[:id])
    respond_with(@noticia)
  end

  def new
    @noticia = Noticia.new
    respond_with(@noticia)
  end

  def edit
    @noticia = Noticia.find(params[:id])
  end

  def create
    @noticia = Noticia.new(params[:noticia])
    @noticia.save
    respond_with(@noticia)
  end

  def update
    @noticia = Noticia.find(params[:id])
    @noticia.update_attributes(params[:noticia])
    redirect_to({:site_id => @noticia.sites[0].name, :controller => 'noticias'}, :notice => (t"successfully_updated"))
  end

  def destroy
    @noticia = Noticia.find(params[:id])
    @noticia.destroy
    respond_with(@noticia)
  end
end
