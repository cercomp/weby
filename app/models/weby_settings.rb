class WebySettings < RailsSettings::CachedSettings
  self.table_name = 'weby_settings'
  attr_accessible :var, :value
end
