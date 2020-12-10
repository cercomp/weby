Skin.where(theme: ['alternative', 'level2', 'level3', 'ufg2']).find_each do |skin|

  i18n = skin.components.find_by(name: 'menu_i18n')
  if i18n
    i18n.settings = '{:dropdown=>"1", :template=>"flag_name", :use_translator=>"1"}'
    i18n.publish = true
    i18n.save!
  end

end
