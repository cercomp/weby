module Sticker
  class BannerSerializer < ActiveModel::Serializer

    attributes :id, :title, :text, :url, :width, :height, :image,
               :size, :publish, :site_id, :position, :new_tab,
               :click_count, :created_at, :updated_at,
               :target_id, :target_type, :shareable,
               :date_begin_at, :date_end_at, :category_list


    def image
      object.repository ? object.repository.archive.url : nil
    end

    def category_list
      current_banner_site.category_list
    end

    def current_banner_site
      @curr_bs ||= object.banner_sites.find_by(site_id: object.site_id)
    end

    def position
      current_banner_site.position
    end
  end
end
