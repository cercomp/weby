class Sites::Admin::BackupsController < ApplicationController
  before_action :require_user
  before_action :check_authorization

  respond_to :html, :json

  def index
    respond_to do |format|
      format.html
  end

  end

  def generate
    require 'zip/zip'
    require 'find'
    require 'fileutils'

    s = current_site
    h = {include: {}}
    h[:include][:pages] = {include: :i18ns} if params[:pages]
    h[:include][:repositories] = {}  if params[:repositories]
    h[:include][:menus] = {include: :root_menu_items } if params[:menus]
    h[:include][:styles] = {}  if params[:styles]
    h[:include][:banners] = {}  if params[:banners]
    h[:include][:root_components] = {}  if params[:root_components]
    h[:include][:extensions] = {}  if params[:extensions]
#    h[:include][:groupings] = {}  if params[:groupings]
#    h[:include][:roles] = {include: :users}  if params[:roles]
    h[:include][:locales] = {}  if params[:locales]

    dir = "tmp/#{s.id}"
    Dir.mkdir("#{dir}") unless Dir.exist?("#{dir}")

    FileUtils.rm_r Dir.glob("#{dir}/*")

    if params[:type] == "JSON"
         File.open(Rails.root.join(dir, "#{s.name}.json"), 'wb') do |file|
            file.write(s.to_json(h) do |json|
              json.messages {Feedback::Message.where(site_id: s.id).each { |message| message.to_xml(skip_instruct: true, builder: json)  }} if params[:messages]
            end)
          end
          filename = "#{dir}/#{s.name}.json"
    else
        File.open(Rails.root.join(dir, "#{s.name}.xml"), 'wb') do |file|
            file.write(s.to_xml(h) do |xml|
              xml.messages {Feedback::Message.where(site_id: s.id).each { |message| message.to_xml(skip_instruct: true, builder: xml)  }} if params[:messages]
            end)
        end
        filename = "#{dir}/#{s.name}.xml"
    end

    zip_dir = Rails.root.join(dir, "#{s.name}.zip")
    repository = "public/uploads/#{s.id}"
    Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE)do |zipfile|
      Find.find(repository) do |path|
        Find.prune if File.basename(path)[0] == ?.
        dest = /#{repository}\/(\w.*)/.match(path)
        begin
          zipfile.add(dest[1],path) if dest
        rescue Zip::ZipEntryExistsError
        end
      end if params[:repositories]
      dest = /#{dir}\/(\w.*)/.match(filename)
      zipfile.add(dest[1],filename) if dest
    end

    zip_data = File.read("#{dir}/#{s.name}.zip")
    send_data(zip_data, type: 'application/zip', filename: "#{s.name}.zip")

  end

  def import

    uploaded_io = params[:upload]

    case uploaded_io.content_type
    when 'text/xml'
      attrs = Hash.from_xml(uploaded_io.read)
    when 'application/json'
      attrs = JSON.parse uploaded_io.read
    when 'application/octet-stream'
      attrs = JSON.parse uploaded_io.read
    end
if attrs
  #    current_site.roles.import(attrs['site']['roles']) if attrs['site']['roles']
  #    current_site.repositories.import(attrs['site']['repositories']) if attrs['site']['repositories']
  #    current_site.banners.import(attrs['site']['banners'], author: current_user.id) if attrs['site']['banners']
      current_site.pages.import(attrs['site']['pages'], author: current_user.id) if attrs['site']['pages']
      current_site.menus.import(attrs['site']['menus']) if attrs['site']['menus']
      current_site.components.import(attrs['site']['root_components']) if attrs['site']['root_components']
      current_site.styles.import(attrs['site']['styles']) if attrs['site']['styles']
      current_site.extensions.import(attrs['site']['extensions']) if attrs['site']['extensions']
end
#    File.open(Rails.root.join('public', "uploads/#{current_site.id}", uploaded_io.original_filename), 'wb') do |file|
#      file.write(uploaded_io.read)
#    end
#    flash[:error] = 'Houve algum erro na importaçao' Colocar mensagens de erro e sucesso
    redirect_to :back
  end

end
