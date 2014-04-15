FactoryGirl.define do
  factory :component do
    sequence(:alias) { |count| "Component #{count}" }
    place_holder 'home'
  end
end
