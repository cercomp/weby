class SearchBoxComponent < Component
  component_settings :width, :align, :show_button

  def show_button?
    show_button.blank? ? false : show_button.to_i == 1
  end
end
