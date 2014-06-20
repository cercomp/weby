# extensions:banners
crumb :sticker_banners do
  link t('breadcrumbs.banners'), admin_banners_path
end

crumb :sticker_banners_new do
  link t('breadcrumbs.new_banner'), new_admin_banner_path
  parent :sticker_banners
end

crumb :sticker_banners_edit do |banner|
  link "#{t('breadcrumbs.edit')} #{banner.title}", edit_admin_banner_path
  parent :sticker_banners
end

crumb :sticker_banners_show do |banner|
  link "#{banner.title}", admin_banner_path
  parent :sticker_banners
end

crumb :banners_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :sticker_banners
end
