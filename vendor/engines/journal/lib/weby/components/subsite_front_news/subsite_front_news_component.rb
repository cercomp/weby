class SubsiteFrontNewsComponent < Component
  component_settings :quant, :source, :sel_site, :tag_as_label, :hide_author, :hide_read_more,
                     :label, :link_to_all

  i18n_settings :label, :link_to_all

  validates :quant, presence: true

  validates :sel_site, presence: true, if: -> { source == 'selected' }

  def hide_author?
    hide_author.blank? ? false : hide_author.to_i == 1
  end

  def hide_read_more?
    hide_read_more.blank? ? false : hide_read_more.to_i == 1
  end

  def tag_as_label?
    tag_as_label.blank? ? false : tag_as_label.to_i == 1
  end

  def source_options
    ['subsites', 'selected']
  end
end
