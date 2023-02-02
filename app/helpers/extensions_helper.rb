module ExtensionsHelper
  # Search for the availables extensions ordering by the I18N name
  def available_extensions_sorted
    # ['teachers', 'feedback']
    Weby.extensions.map { |_name, extension| [t("extensions.#{extension.name}.name"), extension.name] }
  end

  def render_target_page extension_name
    begin
      output = render "#{extension_name}/admin/target_pages"
    rescue ActionView::MissingTemplate
      begin
        output = render "extensions/#{extension_name}/admin/target_pages"
      rescue ActionView::MissingTemplate
        output = render partial: 'none'
      end
    end
    output.html_safe
  end

  ActionView::Helpers::RenderingHelper.module_eval do
    def render_extension_edit(extension, args = {})
      begin
        output = render "#{extension.name}/admin/form"
      rescue ActionView::MissingTemplate
        begin
          output = render "extensions/#{extension.name}/admin/form"
        rescue ActionView::MissingTemplate
          output = render partial: 'none'
        end
      end
      output.html_safe
    end
  end
end
