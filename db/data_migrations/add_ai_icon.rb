Skin.where(theme: ['alternative', 'level2', 'level3', 'ufg2']).find_each do |skin|

  a11y = skin.components.find_by(name: 'menu_accessibility')
  if a11y
    a11y = a11y.specialize
    a11y.information_access_url = 'https://sic.ufg.br/'
    a11y.save!
  end

end