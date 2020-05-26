
Component.where(name: 'image').where("settings like '%marca-ufg%' OR settings like '%marca-ai%'").find_each do |comp|
  component = comp.specialize
  next if component.default_image.match('white')
  if component.contrast_default_image.blank?
    component.contrast_default_image = component.default_image.gsub(/marca\-(ufg|ai)/, 'marca-\1-white')
    component.save
  end
end
