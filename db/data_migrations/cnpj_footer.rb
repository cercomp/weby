Skin.where(theme: ['alternative']).find_each do |skin|
  address = skin.components.find_by(name: 'text', alias: 'Endereço')
  if address
    comp = address.specialize
    index = comp.body.index("<p><span>Avenida Esperan&ccedil;a s/n")
    has_cnpj = !!comp.body.match(/CNPJ/)

    if !index.nil? && !has_cnpj
      comp.body.insert(index, "<p><span>CNPJ: 01.567.601/0001-43</span></p>\r\n")
    end

    comp.save!
  end
end

Skin.where(theme: ['alternative', 'level2', 'level3']).find_each do |skin|
  address = skin.components.find_by(name: 'text', alias: 'Endereço')
  if address
    comp = address.specialize

    if comp.body.match(/01567601\/0001\-43/)
      comp.body.gsub!( /01567601\/0001\-43/, '01.567.601/0001-43')
      comp.save!
    end
  end
end
