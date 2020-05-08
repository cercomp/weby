class NewsAsHomeComponent < Component
  component_settings :page_id, :show_title, :show_info, :html_id, :source_type, :show_as_popup, :popup_position

  validates :page_id, presence: true, if: ->{ source == 'page' }

  def page
    Page.find(page_id) rescue nil
  end

  alias_method :_show_title, :show_title
  def show_title
    _show_title.blank? ? false : _show_title.to_i == 1
  end

  alias_method :_show_info, :show_info
  def show_info
    _show_info.blank? ? false : _show_info.to_i == 1
  end

  def is_popup?
    show_as_popup.blank? ? false : show_as_popup.to_i == 1
  end

  def source_options
    ['page', 'feedback']
  end

  def popup_position_options
    ['left', 'center', 'right']
  end

  def popup_class
    is_popup? ? "popup-modal #{popup_position || 'right'}" : ''
  end

  def source
    source_type.present? ? source_type : source_options.first
  end

  def default_alias
    page = Page.find page_id rescue nil
    page ? page.title : ''
  end
end
