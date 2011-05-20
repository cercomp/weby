class SiteComponentsController < ApplicationController
  layout :choose_layout

  # GET /site_components
  # GET /site_components.xml
  def index
    @site_components = @site.site_components

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_components }
    end
  end

  # GET /site_components/1
  # GET /site_components/1.xml
  def show
    @site_component = @site.site_components.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_component }
    end
  end

  # GET /site_components/new
  # GET /site_components/new.xml
  def new
    @site_component = SiteComponent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_component }
    end
  end

  # GET /site_components/1/edit
  def edit
    @site_component = @site.site_components.find(params[:id])
  end

  # POST /site_components
  # POST /site_components.xml
  def create
    @site_component = SiteComponent.new(params[:site_component])

    respond_to do |format|
      if @site_component.save
        # TODO colocar tradução na mensagem de sucesso
        format.html { redirect_to(site_site_components_url, :notice => 'Componente criado com sucesso.') }
        format.xml  { render :xml => @site_component, :status => :created, :location => @site_component }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_component.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_components/1
  # PUT /site_components/1.xml
  def update
    @site_component = @site.site_components.find(params[:id])

    respond_to do |format|
      if @site_component.update_attributes(params[:site_component])
        # TODO colocar tradução na mensagem de sucesso
        format.html { redirect_to(site_site_components_url, :notice => 'Componente atualizado com sucesso.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_component.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_components/1
  # DELETE /site_components/1.xml
  def destroy
    @site_component = SiteComponent.find(params[:id])
    @site_component.destroy

    respond_to do |format|
      format.html { redirect_to(site_site_components_url) }
      format.xml  { head :ok }
    end
  end
end
