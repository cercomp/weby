FactoryBot.define do
  factory :style do
    association :skin
    sequence(:name) { |count| "Style #{count}" }
  end
end
