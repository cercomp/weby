class Sites::Admin::BackupsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  
  respond_to :html, :json

  def index
    respond_to do |format|
      format.html 
  end

  end

  def generate
    s = current_site    
    h = {include: {}}
    h[:include][:pages] = {include: :i18ns} if params[:pages]
    h[:include][:repositories] = {}  if params[:repositories]
    h[:include][:menus] = {include: :root_menu_items } if params[:menus]    
    h[:include][:styles] = {}  if params[:styles]
    h[:include][:banners] = {}  if params[:banners]
    h[:include][:root_components] = {}  if params[:root_components]
    h[:include][:extensions] = {}  if params[:extensions]
    h[:include][:groupings] = {}  if params[:groupings]
    h[:include][:roles] = {include: :users}  if params[:roles]
    h[:include][:locales] = {}  if params[:locales]

    if params[:type] == "JSON"
    send_data(s.to_json(h) do |json|
        json.messages {Feedback::Message.where(site_id: s.id).each { |message| message.to_xml(skip_instruct: true, builder: json)  }} if params[:messages]
      end,
           :type => 'text/json; charset=UTF-8;',
           :disposition => "attachment; filename=#{s.name}.json") 
    elsif
      send_data(s.to_xml(h) do |xml|
        xml.messages {Feedback::Message.where(site_id: s.id).each { |message| message.to_xml(skip_instruct: true, builder: xml)  }} if params[:messages]
      end,
           :type => 'text/xml; charset=UTF-8;',
           :disposition => "attachment; filename=#{s.name}.xml")
    end
    
  end

  def import

    uploaded_io = params[:upload]

    if uploaded_io.content_type == 'text/xml'
      attrs = Hash.from_xml(uploaded_io.read)      
    elsif uploaded_io.content_type == 'application/octet-stream'
      attrs = JSON.parse uploaded_io.read
    end

#      current_site.roles.import(attrs['site']['roles']) if attrs['site']['roles']
    current_site.pages.import(attrs['site']['pages'], author: current_user.id) if attrs['site']['pages']
    current_site.components.import(attrs['site']['root_components']) if attrs['site']['root_components']
    current_site.menus.import(attrs['site']['menus']) if attrs['site']['menus']
    current_site.styles.import(attrs['site']['styles']) if attrs['site']['styles']
    current_site.banners.import(attrs['site']['banners'], author: current_user.id) if attrs['site']['banners']
    current_site.extensions.import(attrs['site']['extensions']) if attrs['site']['extensions']
    current_site.locales.import(attrs['site']['locales']) if attrs['site']['locales']

#    File.open(Rails.root.join('public', "uploads/#{current_site.id}", uploaded_io.original_filename), 'wb') do |file|
#      file.write(uploaded_io.read)
#    end  

    redirect_to :back
  end
  
end
