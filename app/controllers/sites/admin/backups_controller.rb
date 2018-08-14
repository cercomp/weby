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
    h[:include][:pages] = { include: [:i18ns, :related_files] } if params[:pages]
    h[:include][:own_news] = { include: { i18ns: {}, related_files: {}, own_news_site: {include: :categories} } } if params[:news]
    #h[:include][:news_sites] = { include: [:categories ] } if params[:news]
    h[:include][:events] = { include: [:categories, :i18ns, :related_files] } if params[:events]
    h[:include][:repositories] = {}  if params[:repositories]
    h[:include][:banners] = { include: :categories } if params[:banners]
    h[:include][:menus] = { include: :root_menu_items } if params[:menus]
    #h[:include][:styles] = {}  if params[:styles]
    #h[:include][:root_components] = {}  if params[:root_components]
    h[:include][:skins] = { include: [:styles, :root_components] } if params[:themes]
    h[:include][:extensions] = {}  if params[:extensions]
    h[:include][:locales] = {}  if params[:locales]
    h[:include][:messages] = {} if params[:messages]

    dir = "tmp/#{s.id}"
    Dir.mkdir("#{dir}") unless Dir.exist?("#{dir}")

    FileUtils.rm_r Dir.glob("#{dir}/*")

    if params[:type] == 'JSON'
      File.open(Rails.root.join(dir, "#{s.name}.json"), 'wb') do |file|
        file.write s.to_json(h)
      end
      filename = "#{dir}/#{s.name}.json"
    else
      File.open(Rails.root.join(dir, "#{s.name}.xml"), 'wb') do |file|
        file.write s.to_xml(h)
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
    case uploaded_io.original_filename
    when /\.xml/
      parser = Nori.new
      attrs = parser.parse(uploaded_io.read)
    when /\.json/
      attrs = JSON.parse uploaded_io.read
    end

    attrs = attrs['site'] if attrs['site']

    if attrs
      current_site.repositories.import(attrs['repositories'], site_id: current_site.id) if attrs['repositories']
      current_site.banners.import(attrs['banners'], user: current_user.id) if attrs['banners']
      current_site.pages.import(attrs['pages'], user: current_user.id, site_id: current_site.id) if attrs['pages']
      current_site.own_news.import(attrs['own_news'], user: current_user.id, site_id: current_site.id) if attrs['own_news']
      #current_site.news_sites.import(attrs['news_sites'], user: current_user.id, site_id: current_site.id) if attrs['own_news']
      current_site.events.import(attrs['events'], user: current_user.id, site_id: current_site.id) if attrs['events']
      current_site.menus.import(attrs['menus']) if attrs['menus']
      #current_site.components.import(attrs['root_components'], site_id: current_site.id) if attrs['root_components']
      #current_site.styles.import(attrs['styles']) if attrs['styles']
      current_site.skins.import(attrs['skins'], site_id: current_site.id) if attrs['skins']
      current_site.extensions.import(attrs['extensions']) if attrs['extensions']
      current_site.messages.import(attrs['messages']) if attrs['messages']
    end
    #    File.open(Rails.root.join('public', "uploads/#{current_site.id}", uploaded_io.original_filename), 'wb') do |file|
    #      file.write(uploaded_io.read)
    #    end
    #    flash[:error] = 'Houve algum erro na importaçao' Colocar mensagens de erro e sucesso
    flash[:success] = "Processo concluído"
    redirect_to :back
  end
end
