class SiteSerializer < ActiveModel::Serializer

  attributes :id, :domain, :head_html, :name, :parent_id, :per_page, :per_page_default, :restrict_theme,
  :settings, :show_pages_author, :show_pages_created_at, :show_pages_updated_at, :status, :theme_name,
  :title, :created_at, :updated_at, :url, :view_count, :body_width, :description

  def theme_name
    object.theme.name
  end

end

