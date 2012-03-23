class GovBarComponent < SiteComponent
  component_name :gov_bar
  register_settings :background

  validates :background, :presence => true
end
