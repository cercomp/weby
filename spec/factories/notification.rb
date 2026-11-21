FactoryBot.define do
  factory :notification do
    association :user
    sequence(:title) { |count| "Notification #{count}" }
  end
end
