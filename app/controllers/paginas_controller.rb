class PaginasController < ApplicationController
  layout :choose_layout

  def index
    @paginas = Pagina.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @paginas }
    end
  end

  def show
    @pagina = Pagina.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pagina }
    end
  end

  def new
    @pagina = Object.const_get(params[:type]).new
    #@pagina = Pagina.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pagina }
    end
  end

  def edit
    @pagina = Pagina.find(params[:id])
  end

  def create
    @pagina = Object.const_get(params[:pagina][:type]).new(params[:pagina])
    #@pagina = Pagina.new(params[:pagina])

    respond_to do |format|
      if @pagina.save
        flash[:notice] = 'Pagina was successfully created.'
        format.html { redirect_to(@pagina) }
        format.xml  { render :xml => @pagina, :status => :created, :location => @pagina }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pagina.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @pagina = Pagina.find(params[:id])

    respond_to do |format|
      if @pagina.update_attributes(params[@pagina.class.name.underscore])
        flash[:notice] = 'Pagina was successfully updated.'
        format.html { redirect_to(@pagina) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pagina.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @pagina = Pagina.find(params[:id])
    @pagina.destroy

    respond_to do |format|
      format.html { redirect_to(paginas_url) }
      format.xml  { head :ok }
    end
  end
end
