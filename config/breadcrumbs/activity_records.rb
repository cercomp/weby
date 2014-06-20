# activity_records
crumb :activity_records do
  link t('breadcrumbs.activity_records'), site_admin_activity_records_path
end

crumb :activity_records_details do
  link t('breadcrumbs.activity_records_details'), site_admin_activity_record_path
  parent :activity_records
end

crumb :activity_records_search do |search|
  link "#{t('breadcrumbs.search')}/ #{search}"
  parent :activity_records
end
