class GovBarComponent < SiteComponent
  register_settings :background

  validates :background, :presence => true
end
