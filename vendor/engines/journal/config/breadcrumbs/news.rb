# extensions:news
crumb :news do
  link t('breadcrumbs.news'), admin_news_index_path
end

crumb :news_new do
  link t('breadcrumbs.new_news'), new_admin_news_path
  parent :news
end

crumb :news_show do |news|
  link "#{news.title}", admin_news_path(news)
  parent :news
end

crumb :news_edit do |news|
  link "#{t('breadcrumbs.edit')} #{news.title}", edit_admin_news_path(news)
  parent :news
end

crumb :news_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :news
end

crumb :news_fronts do
  link t('breadcrumbs.fronts'), fronts_admin_news_index_path
  parent :news
end

crumb :news_newsletter do |news|
  link t('breadcrumbs.newsletter'), admin_newsletter_histories_path(news)
  parent :news
end

crumb :news_recycle_bin do
  link t('recycle_bin')
  parent :news
end
