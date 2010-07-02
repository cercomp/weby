class PaginasController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    @paginas = Pagina.all
    respond_with(@paginas)
  end

  def show
    @pagina = Pagina.find(params[:id])
    respond_with(@pagina)
  end

  def new
    @pagina = Object.const_get(params[:type]).new
    #@pagina = Pagina.new
    respond_with(@pagina)
  end

  def edit
    @pagina = Pagina.find(params[:id])
  end

  def create
    @pagina = Object.const_get(params[:pagina][:type]).new(params[:pagina])
    #@pagina = Pagina.new(params[:pagina])
    @pagina.save
    respond_with(@pagina)
  end

  def update
    @pagina = Pagina.find(params[:id])
    @pagina.update_attributes(params[@pagina.class.name.underscore])
    respond_with(@pagina)
  end

  def destroy
    @pagina = Pagina.find(params[:id])
    @pagina.destroy
    respond_with(@pagina)
  end
end
