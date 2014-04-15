FactoryGirl.define do
  factory :page do
    sequence(:title) { |count| "Page #{count}" }
  end
end
