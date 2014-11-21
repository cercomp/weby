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
    h = { include: {} }
    h[:include][:pages] = { include: [:i18ns, :related_files]} if params[:pages]
    h[:include][:repositories] = {}  if params[:repositories]
    h[:include][:menus] = { include: :root_menu_items } if params[:menus]
    h[:include][:styles] = {}  if params[:styles]
    h[:include][:root_components] = {}  if params[:root_components]
    h[:include][:extensions] = {}  if params[:extensions]
    h[:include][:locales] = {}  if params[:locales]

    dir = "tmp/#{s.id}"
    Dir.mkdir("#{dir}") unless Dir.exist?("#{dir}")

    FileUtils.rm_r Dir.glob("#{dir}/*")

    if params[:type] == 'JSON'
      json = s.as_json(h)
      json['messages'] = Feedback::Message.where(site_id: s.id).as_json if params[:messages]
      json['banners']  = Sticker::Banner.where(site_id: s.id).as_json(include: :categories ) if params[:banners]
      json['news']     = Journal::News.where(site_id: s.id).as_json(include: [:categories, :i18ns, :related_files]) if params[:news]
      json['events']   = Calendar::Event.where(site_id: s.id).as_json(include: [:categories, :i18ns, :related_files]) if params[:events]

      File.open(Rails.root.join(dir, "#{s.name}.json"), 'wb') do |file|
        file.write(json.to_json)
      end
      filename = "#{dir}/#{s.name}.json"
    else
      File.open(Rails.root.join(dir, "#{s.name}.xml"), 'wb') do |file|
        file.write(s.to_xml(h) do |xml|
          xml.messages(type: 'array') { Feedback::Message.where(site_id: s.id).each { |message| message.to_xml(skip_instruct: true, builder: xml)  } } if params[:messages]
          xml.banners(type: 'array')  { Sticker::Banner.where(site_id: s.id).each { |banner| banner.to_xml(skip_instruct: true, builder: xml, include: :categories ) } } if params[:banners]
          xml.news(type: 'array')     { Journal::News.where(site_id: s.id).each { |news| news.to_xml(skip_instruct: true, builder: xml, include: [:categories, :i18ns]) } } if params[:news]
          xml.events(type: 'array')   { Calendar::Event.where(site_id: s.id).each { |event| event.to_xml(skip_instruct: true, builder: xml, include: [:categories, :i18ns] ) } } if params[:events]
        end)
      end
      filename = "#{dir}/#{s.name}.xml"
    end

    zipname = "#{s.name}_#{params[:type].downcase}.zip"
    zip_dir = Rails.root.join(dir, zipname)
    repository = "public/up/#{s.id}"
    Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE)do |zipfile|
      Find.find(repository) do |path|
        Find.prune if File.basename(path)[0] == '.'
        dest = /#{repository}\/(\w.*)/.match(path)
        begin
          zipfile.add(dest[1], path) if dest
        rescue Zip::ZipEntryExistsError
        end
      end if params[:repositories]
      dest = /#{dir}\/(\w.*)/.match(filename)
      zipfile.add(dest[1], filename) if dest
    end

    zip_data = File.read("#{dir}/#{zipname}")
    send_data(zip_data, type: 'application/zip', filename: zipname)
  end

  def import
    uploaded_io = params[:upload]
    Import::Application::CONVAR["repository"] = {}
    Import::Application::CONVAR["menu"] = {}
    case uploaded_io.content_type
      when 'text/xml'
        attrs = Hash.from_xml(uploaded_io.read)
      when 'application/json', 'application/octet-stream'
        attrs = JSON.parse uploaded_io.read
    end

    attrs = attrs['site'] if attrs['site']

    if attrs
      current_site.repositories.import(attrs['repositories']) if attrs['repositories']
      Sticker::Banner.where(site_id: current_site.id).import(attrs['banners'], user: current_user.id) if attrs['banners']
      current_site.pages.import(attrs['pages'], user: current_user.id, site_id: current_site.id) if attrs['pages']
      Journal::News.where(site_id: current_site.id).import(attrs['news'], user: current_user.id, site_id: current_site.id) if attrs['news']
      Calendar::Event.where(site_id: current_site.id).import(attrs['events'], user: current_user.id, site_id: current_site.id) if attrs['events']
      current_site.menus.import(attrs['menus']) if attrs['menus']
      current_site.components.import(attrs['root_components'], site_id: current_site.id) if attrs['root_components']
      current_site.styles.import(attrs['styles']) if attrs['styles']
      current_site.extensions.import(attrs['extensions']) if attrs['extensions']
      #TODO import messages
    end
    #    File.open(Rails.root.join('public', "uploads/#{current_site.id}", uploaded_io.original_filename), 'wb') do |file|
    #      file.write(uploaded_io.read)
    #    end
    #    flash[:error] = 'Houve algum erro na importaçao' Colocar mensagens de erro e sucesso
    redirect_to :back
  end
end
