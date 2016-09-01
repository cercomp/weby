class PageSerializer < ActiveModel::Serializer

  attributes :id, :slug, :publish,
             :site_id, :view_count,
             :created_at, :updated_at, :deleted_at

  attributes :title, :text, :locale

  def locale
    I18n.locale
  end

  def slug
    object.to_param.to_s
  end
end

