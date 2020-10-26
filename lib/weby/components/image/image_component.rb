class ImageComponent < Component
  component_settings :repository_id, :contrast_repository_id, :size, :height, :width, :target_type,
             :target_id, :url, :new_tab, :html_class, :default_image, :default_image_alt,
             :contrast_default_image, :title, :hide_for_sr

  i18n_settings :repository_id, :contrast_repository_id, :title

  #belongs_to :repository, optional: true

  alias_method :_new_tab, :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  def hide_for_sr?
    hide_for_sr.blank? ? false : hide_for_sr.to_i == 1
  end

  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }
  validates :repository_id, presence: true, unless: :default_image

  belongs_to :target, polymorphic: true, optional: true

  def repository
    @repository ||= Repository.find_by(id: repository_id)
  end

  def target
    target_type.constantize.find_by(id: target_id) if target_type.present?
  end

  def html_tag
    tag = :div
    if (repository.present? && (repository.image? || repository.svg?)) || default_image.present?
      tag = :figure if !title.present?
    end
    tag
  end
end
