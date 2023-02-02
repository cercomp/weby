class Sites::Admin::AlbumTagsController < ::ApplicationController
  before_action :require_user
  before_action :check_authorization
  before_action :find_album_tag, only: [:edit, :update, :destroy, :show]

  def index
    @album_tags = current_site.album_tags
  end

  def edit
  end

  def update
    if @album_tag.update(album_tag_params)
      redirect_to(site_admin_album_tags_path,
                  flash: { success: t('successfully_updated_param', param: @album_tag.name) })
    else
      render action: 'edit'
    end
  end

  def new
    @album_tag = current_site.album_tags.new
  end

  def create
    @album_tag = current_site.album_tags.new(album_tag_params)
    @album_tag.user = current_user
    if @album_tag.save
      redirect_to site_admin_album_tags_path
    else
      render :new
    end
  end

  def destroy
    @album_tag.destroy

    redirect_to site_admin_album_tags_path
  end

  private

  def find_album_tag
    @album_tag = if params[:id].match(/^\d+$/)
      current_site.album_tags.find(params[:id])
    else
      current_site.album_tags.find_by(slug: params[:id])
    end
  end

  def album_tag_params
    params.require(:album_tag).permit(:name, :description)
  end

end
