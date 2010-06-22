class EventosController < ApplicationController
  layout :choose_layout

  before_filter :require_user

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
    respond_with(@evento)
  end

  def destroy
    @evento = Evento.find(params[:id])
    @evento.destroy
    respond_with(@evento)
  end
end
