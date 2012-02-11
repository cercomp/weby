module RepositoriesSearchHelper
  def file_selected(file, name, label_value, options = {})
    options.merge!({ class: "boolean optional",
                     id: "#{label_value}_#{file.id}" })
    check_box_tag(name, file.id, true, options)
  end

  def file_selector(many, name, value = "1", checked = false, options = {})
    if many.to_s == 'true'
      check_box_tag(name, value, checked, options)
    else
      radio_button_tag(name, value, checked, options)
    end
  end
end
