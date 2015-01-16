module TargetDialogHelper
  def target_dialog(polymorphic = false, editable_url = true)
    content_for :body_end do
      @target_included = @target_included.to_i + 1
      render partial: 'sites/admin/pages/target_dialog_search', locals: { polymorphic: polymorphic, editable_url: editable_url }  if @target_included == 1
    end
  end

  def target_dialog_input(form_builder, target_name, polymorphic = false, editable_url = true)
    target_dialog polymorphic, editable_url
    render partial: 'sites/admin/pages/target_dialog_input', locals: { f: form_builder, target_name: target_name, polymorphic: polymorphic, editable_url: editable_url }
  end

  def common_pages
    [
      { title: t('common_pages.site_path.title'), description: t('common_pages.site_path.description'), url: main_app.site_path },
      { title: t('common_pages.rss_feed_path.title'), description: t('common_pages.rss_feed_path.description'), url: main_app.site_feed_path(format: :rss) },
      { title: t('common_pages.atom_feed_path.title'), description: t('common_pages.atom_feed_path.description'), url: main_app.site_feed_path(format: :atom) },
      { title: t('common_pages.pages_path.title'), description: t('common_pages.pages_path.description'), url: main_app.site_pages_path },
      { title: t('common_pages.sitemap_path.title'), description: t('common_pages.sitemap_path.description'), url: main_app.sitemap_site_pages_path }
    ]
  end
end
