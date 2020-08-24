
Component.where(name: 'image').find_each do |comp|
  component = comp.specialize

  changes = false
  if component.default_image.to_s.match(/marca\-ai/)
    component.default_image_alt = "Acesso à informação"
    change = true
  end

  if component.default_image.to_s.match(/(marca\-ufg|UFG_logo|UFG_vertical|Marca_Vertical\.png|ufg_topo|ufg_barra)/)
    component.default_image_alt = "Logo da UFG"
    change = true
  end

  if component.default_image.to_s.match(/(ic\-social|twitter|facebook|youtube|instagram|ic\-radio|ic\-tv|marca\-ai|banner\-1\.jpg|linkedin|flirck|ufg2\/ic\-)/i)
    component.hide_for_sr = "1"
    change = true
  end
  if component.title.to_s.match(/(TV\sUFG|Rádio\sUFG|Youtube\sUFG)/)
    component.hide_for_sr = "1"
    change = true
  end

  component.save if change
end
