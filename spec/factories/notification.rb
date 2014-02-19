FactoryGirl.define do
  factory :notification do
    sequence(:title) { |count| "Notification #{count}" }
  end
end
