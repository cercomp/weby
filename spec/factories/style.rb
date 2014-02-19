FactoryGirl.define do
  factory :style do
    sequence(:name) { |count| "Style #{count}" }
  end
end
