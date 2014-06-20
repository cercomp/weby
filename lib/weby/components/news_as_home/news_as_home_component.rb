class NewsAsHomeComponent < Component
  component_settings :page_id, :show_title, :show_info

  validates :page_id, presence: true

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

  def default_alias
    page = Page.find page_id rescue nil
    page ? page.title : ''
  end
end
