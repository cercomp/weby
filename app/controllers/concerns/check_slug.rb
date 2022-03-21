module CheckSlug
  extend ActiveSupport::Concern

  included do
    # TODO
  end

  def check_slug
    check_query = "slug = ?"
    check_params = [params[:slug]]
    if params[:id].present?
      check_query += " AND id != ?"
      check_params << params[:id]
    end
    is_taken = resource_class.classify.constantize.where(check_query, *check_params).exists?
    render json: {
      taken: is_taken,
      slug: params[:slug],
      empty: params[:slug].blank?,
      message: is_taken ? t('slug_taken') : t('slug_ok')
    }
  end

  private

end
