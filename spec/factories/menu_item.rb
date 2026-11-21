FactoryBot.define do
  factory :menu_item do
    association :menu
    url { 'http://example.com' }
    publish { true }
    after(:build) do |item, evaluator|
      if item.i18ns.empty?
        locale = item.menu&.site&.locales&.first || Locale.first || evaluator.association(:locale)
        item.i18ns.build(title: 'Menu Item', locale_id: locale.id)
      end
    end
  end
end
