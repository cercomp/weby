module TargetDialogHelper

  def target_dialog_input(form_builder, target_name, polymorphic=false, editable_url=true)
    render partial: "sites/admin/pages/target_dialog_input", locals: {f: form_builder, target_name: target_name, polymorphic: polymorphic, editable_url: editable_url}
  end

  def common_pages
    [
      {title: t("common_pages.site_path.title"), description: t("common_pages.site_path.description"), url: site_path},
      {title: t("common_pages.rss_feed_path.title"), description: t("common_pages.rss_feed_path.description"), url: site_feed_path(format: :rss)},
      {title: t("common_pages.atom_feed_path.title"), description: t("common_pages.atom_feed_path.description"), url: site_feed_path(format: :atom)},
      {title: t("common_pages.pages_path.title"), description: t("common_pages.pages_path.description"), url: site_pages_path},
      {title: t("common_pages.published_path.title"), description: t("common_pages.published_path.description"), url: published_site_pages_path},
      {title: t("common_pages.news_path.title"), description: t("common_pages.news_path.description"), url: news_site_pages_path},
      {title: t("common_pages.events_path.title"), description: t("common_pages.events_path.description"), url: events_site_pages_path}
    ]
  end

end
