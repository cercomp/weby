FactoryGirl.define do
  factory :locale do
    sequence(:name) { |count| "Locale #{count}" }
  end
end
