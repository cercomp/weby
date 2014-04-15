FactoryGirl.define do
  factory :grouping do
    sequence(:name) { |count| "Grouping #{count}" }
  end
end
