module RepositoriesSearchHelper
  def file_selected(file, name, label_value, options = {})
    options.merge!({ class: "boolean optional",
                     id: "#{label_value}_#{file.id}" })
    check_box_tag(name, file.id, true, options)
  end
end
