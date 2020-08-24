Skin.where(theme: ['alternative', 'level2', 'level3', 'ufg2']).each do |skin|

  search = skin.components.find_by(name: 'search_box')
  if search
    next_comp = skin.components.find_by(place_holder: search.place_holder, position: search.position+1)
    if next_comp.blank? || !next_comp.settings.to_s.match(/search-toggle/)
      skin.components.where(place_holder: search.place_holder).where("position > ?", search.position).update_all("position = position + 1")
      skin.components.create!({
        place_holder: search.place_holder,
        settings: "{:html_class=>\"search-toggle\", :put_at_end=>\"0\", :body=>{\"pt-BR\"=>\"<button type=\\\"button\\\" title=\\\"Abrir formulário de pesquisa\\\" data-alt-title=\\\"Fechar formulário de pesquisa\\\"></button>\", \"en\"=>\"\", \"es\"=>\"\"}}",
        name: "blank",
        position: search.position + 1,
        publish: true,
        visibility: 0,
        alias: "Botão pesquisa - abre/fecha"
      })
    end
  end

  ### update menu handle
  menu_handle = skin.components.where(name: 'blank').find_each do |comp|
    next unless comp.settings.match(/menu-handle/)
    c = comp.specialize
    c.body = "<button class=\"menu-handle\"><span class=\"icon\"></span><span>Menu</span></button>"
    c.save!
  end

end
