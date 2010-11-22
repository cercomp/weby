class EventosController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    @eventos = Evento.all
    respond_with(@eventos)
  end

  def show
    @evento = Evento.find(params[:id])
    respond_with(@evento)
  end

  def new
    @evento = Evento.new
    respond_with(@evento)
  end

  def edit
    @evento = Evento.find(params[:id])
  end

  def create
    @evento = Evento.new(params[:evento])
    @evento.save
    respond_with(@evento)
  end

  def update
    @evento = Evento.find(params[:id])
    @evento.update_attributes(params[:evento])
    redirect_to({:site_id => @evento.sites[0].name, :controller => 'eventos', :action => 'index'}, :notice => (t"successfully_updated"))
  end

  def destroy
    @evento = Evento.find(params[:id])
    @evento.destroy
    respond_with(@evento)
  end
end
