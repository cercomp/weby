class Admin::GroupingsController < Admin::BaseController
  before_action :set_grouping, only: [:edit, :update, :destroy]

  respond_to :html, :xml

  def index
    @groupings = Grouping.all
  end

  def new
    @grouping = Grouping.new
  end

  def create
    @grouping = Grouping.new(grouping_params)
    @grouping.save

    respond_with(@grouping, location: admin_groupings_path)
  end

  def edit
  end

  def update
    @grouping.update(grouping_params)

    respond_with(@grouping, location: admin_groupings_path)
  end

  def destroy
    @grouping.destroy

    respond_with(@grouping, location: admin_groupings_path)
  end

  private

  def set_grouping
    resource
  end

  def grouping_params
    params.require(:grouping).permit(:name, :hidden, {site_ids: []})
  end
end
