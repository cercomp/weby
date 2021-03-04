Skin.where(theme: ['alternative', 'level2', 'level3', 'ufg2', 'ufg']).each do |skin|

  search = skin.components.find_by(name: 'search_box')
  if search
    component = search.specialize
    component.action = 'search'
    component.save!
  end
end