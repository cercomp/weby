
## Migrate components to comply with the new layout of the ufg theme

Skin.where(theme: 'ufg').each do |skin|

  comps = skin.components

  Weby::Themes.theme('ufg').components.select{|place, c| place == 'top' }['top'].each do |component|

    comp = comps.detect{|c| c.name == component.name && c.alias == component.alias }

    if comp
      comp.update(position: component.position)
    else
      skin.components.create(
        name: component.name,
        alias: component.alias,
        settings: component.settings,
        position: component.position
      )
    end

  end



end