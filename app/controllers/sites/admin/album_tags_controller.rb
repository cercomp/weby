class Sites::Admin::AlbumTagsController < ::ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @album_tags = current_site.album_tags
  end

  def edit
    @album_tag =  current_site.album_tags.find(params[:id])
  end

  def update
    @album_tag =  current_site.album_tags.find(params[:id])
    if @album_tag.update(album_tag_params)
      redirect_to(site_admin_album_tags_path,
                  flash: { success: t('successfully_updated_param', param: t('album_tag')) })
    else
      render action: 'edit'
    end
  end

  def new
    @album_tag = current_site.album_tags.new
  end

  def create
    @album_tag = current_site.album_tags.new(album_tag_params)
    if @album_tag.save
      redirect_to site_admin_album_tags_path
    else
      render :new
    end
  end

  def destroy
    current_site.album_tags.find(params[:id]).destroy

    redirect_to site_admin_album_tags_path
  end

  private

  def album_tag_params
    params.require(:album_tag).permit(:name, :description)
  end

end
