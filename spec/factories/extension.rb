FactoryGirl.define do
  factory :extension do
    sequence(:name) { |count| "Extension #{count}" }
  end
end
