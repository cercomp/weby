FactoryGirl.define do
  factory :role do
    sequence(:name) { |count| "Papel #{count}" }
  end
end
