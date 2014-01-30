module LocalesHelper
  def flag(locale, size = '24', options = {})
    options.reverse_merge!({title: t(locale.name)})
    
    image_tag("flags/#{size}/#{locale.flag}", options)
  end

  def available_locales obj
    (obj.locales | current_site.locales).sort
  end

  def each_i18n_tab locales=current_site.locales
    @tab_count = @tab_count.to_i + 1
    content_tag :div, class: "tabbable i18n" do
      tabs = content_tag :ul, class: "nav nav-tabs" do
        locales.each_with_index.map do |locale, index|
          content_tag :li, link_to(locale_with_name(locale, '16'), "#tab_#{locale}#{@tab_count}", data: {toggle: 'tab'}), class: (index == 0 ? "active" : "")
        end.join('').html_safe
      end
      content = content_tag :div, class: "tab-content" do
        locales.each_with_index.map do |locale, index|
          content_tag :div, id: "tab_#{locale.name}#{@tab_count}", class: "tab-pane#{index == 0 ? " active" : ""}" do
            yield(locale) if block_given?
          end
        end.join('').html_safe
      end
      tabs + content
    end
  end
end