FactoryBot.define do
  factory :page do
    association :site
    association :user
    publish { true }
    after(:build) do |page, evaluator|
      if page.i18ns.empty?
        locale = page.site&.locales&.first || Locale.first || evaluator.association(:locale)
        page.i18ns.build(title: 'Page Title', text: 'Page text', locale_id: locale.id)
      end
    end
  end
end
