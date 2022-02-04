Skin.where(theme: ['level2','alternative']).each do |skin|

  group = skin.components.find_by(alias: 'Ícones sociais')  
  if group
    max_pos = skin.components.where(place_holder: group.id.to_s).maximum(:position)
    skin.components.create!({
      place_holder: group.id,
      settings: "{:size=>\"\", :width=>\"\", :height=>\"\", :url=>\"http://www.linkedin.com\", :target_id=>\"\", :target_type=>\"\", :new_tab=>\"1\", :html_class=>\"social-icon\", :default_image=>\"level2/ic-linkedin.svg\", :title=>{\"pt-BR\"=>\"\", \"en\"=>\"\"}, :hide_for_sr=>\"1\"}",
      name: "image",
      position: max_pos + 1,
      publish: false,
      visibility: 0,
      alias: "Linkedin"
    }) if !skin.components.exists?(place_holder: group.id.to_s, alias: 'Linkedin') 
    skin.components.create!({
      place_holder: group.id,
      settings: "{:size=>\"\", :width=>\"\", :height=>\"\", :url=>\"http://www.whatsapp.com\", :target_id=>\"\", :target_type=>\"\", :new_tab=>\"1\", :html_class=>\"social-icon\", :default_image=>\"level2/ic-whatsapp.svg\", :title=>{\"pt-BR\"=>\"\", \"en\"=>\"\"}, :hide_for_sr=>\"1\"}",
      name: "image",
      position: max_pos + 2,
      publish: false,
      visibility: 0,
      alias: "Whatsapp"
    }) if !skin.components.exists?(place_holder: group.id.to_s, alias: 'Whatsapp')     
  end
end