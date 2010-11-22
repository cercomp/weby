class InformativosController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    @informativos = Informativo.all
    respond_with(@informativos)
  end

  def show
    @informativo = Informativo.find(params[:id])
    respond_with(@informativo)
  end

  def new
    @informativo = Informativo.new
    respond_with(@informativo)
  end

  def edit
    @informativo = Informativo.find(params[:id])
  end

  def create
    @informativo = Informativo.new(params[:informativo])
    @informativo.save
    respond_with(@informativo)
  end

  def update
    @informativo = Informativo.find(params[:id])
    @informativo.update_attributes(params[:informativo])
    redirect_to({:site_id => @informativo.sites[0].name, :controller => 'informativos', :action => 'index'}, :notice => (t"successfully_updated"))
  end

  def destroy
    @informativo = Informativo.find(params[:id])
    @informativo.destroy
    respond_with(@informativo)
  end
end
