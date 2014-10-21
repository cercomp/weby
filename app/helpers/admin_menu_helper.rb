# coding: utf-8
module AdminMenuHelper
  def build_admin_menu
    content = content_menu_items
    extensions = extensions_menu_items
    [].tap do |result|
      result << extensions[:first]
      content.each do |name, menu_item|
        result << extensions["before_#{name}".to_sym]
        result << menu_item
        result << extensions["after_#{name}".to_sym]
      end
      result << extensions[:last]
    end.flatten.compact.join.html_safe
  end

  private

  def content_menu_items
    {}.tap do |result|
      result[:archives] = menu_item_to(t(".archives"), main_app.site_admin_repositories_path) if check_permission(Sites::Admin::RepositoriesController, [:index])
      result[:pages] = menu_item_to(t(".pages"), main_app.site_admin_pages_path) if check_permission(Sites::Admin::PagesController, [:index])
      result[:menus] = menu_item_to(t(".menus"), main_app.site_admin_menus_path) if check_permission(Sites::Admin::MenusController, [:index])
    end
  end

  #*Grouped by menu_position
  def extensions_menu_items
    {}.tap do |result|
      current_site.extensions.sort_by{|e| t("extensions.#{e.name}.name") }.each do |extension|
        position = Weby.extensions[extension.name.to_sym].menu_position
        result[position] ||= []
        result[position] << menu_item_to(t("extensions.#{extension.name}.name"), "/admin/#{extension.name}")
      end if check_permission(Sites::Admin::ExtensionsController, [:index])
    end
  end
end
