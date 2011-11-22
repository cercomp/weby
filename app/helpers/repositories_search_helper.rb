module RepositoriesSearchHelper
  def file_selector(multiplicity, name, value = "1", checked = false, options = {})
    if multiplicity == "other"
      check_box_tag(name, value, checked, options)
    else
      radio_button_tag(name, value, checked, options)
    end
  end
end
