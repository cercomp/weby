FactoryGirl.define do
  factory :grouping do
    sequence(:name) { |count| "Group#{count}" }
  end
end
