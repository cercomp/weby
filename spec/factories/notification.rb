FactoryGirl.define do
  factory :notification do
    sequence(:title) { |count| "Notification#{count}" }
    body "body_for_notification"
  end
end
