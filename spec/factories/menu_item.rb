FactoryGirl.define do
  factory :menu_item do
    sequence(:title) { |count| "Item#{count}" }
    sequence(:position) { |count| "#{count}" }
  end
end
