class YoutubeWrapComponent < Component
  include HasYoutubeUrl

  component_settings :url, :html_class, :width, :height, :start, :controls, :privacy

  def show_controls?
    controls.blank? ? true : controls.to_i == 1
  end

  def is_privacy?
    privacy.blank? ? false : privacy.to_i == 1
  end

  validates :url, presence: true
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }

end
