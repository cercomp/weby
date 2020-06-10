FactoryGirl.define do
  factory :site do
    sequence(:name) { |count| "site#{count}" }
    sequence(:title) { |count| "Site #{count}" }
  end
end
