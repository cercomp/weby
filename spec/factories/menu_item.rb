FactoryGirl.define do
  factory :menu_item do
    sequence(:title) { |count| "Menu item #{count}" }
  end
end
