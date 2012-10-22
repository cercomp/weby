class BannerListComponent < Component
  component_settings :category, :orientation

  validates :category, presence: true

  def default_alias
    self.category
  end

end
