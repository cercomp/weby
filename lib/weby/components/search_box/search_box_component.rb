class SearchBoxComponent < Component
  component_settings :width, :align, :show_button, :action

  def show_button?
    show_button.blank? ? false : show_button.to_i == 1
  end

  def action_options
    [
      :choose,
      :news,
      :pages,
      :events,
      :search
    ]
  end

  def form_action
    case action
    when 'pages'
      '/pages'
    when 'events'
      '/events'
    when 'search'
      '/search'
    else
      '/news'
    end
  end
end
