class MenusController < ApplicationController
  layout :choose_layout
  
  before_filter :require_user

  respond_to :html, :xml

  def index
    @esquerdo = Menu.find(:all, :conditions => {:position => "Esquerdo"})
    @direito = Menu.find(:all, :conditions => {:position => "Direito"})
    @superior = Menu.find(:all, :conditions => {:position => "Superior"})
  end

  def show
    @menu = Menu.find(params[:id])
    respond_with(@menu)
  end

  def new
    @menu = Menu.new
    respond_with(@menu)
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def create
    @menu = Menu.new(params[:menu])
    respond_with(@menu)
    @menu.save
  end

  def update
    @menu = Menu.find(params[:id])
    @menu.update_attributes(params[:menu])
    respond_with(@menu)
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy
    respond_with(@menu)
  end
end
