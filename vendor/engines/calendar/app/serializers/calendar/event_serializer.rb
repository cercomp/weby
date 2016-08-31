module Calendar
  class EventSerializer < ActiveModel::Serializer

    attributes :id, :category_list, :slug, :image,
               :site_id, :email, :url, :kind, :view_count,
               :begin_at, :end_at,
               :created_at, :updated_at, :deleted_at

    attributes :name, :information, :place, :locale

    def image
      object.image ? object.image.archive.url : nil
    end

    def locale
      I18n.locale
    end

    def slug
      object.to_param.to_s
    end

  end
end
