FactoryBot.define do
  factory :component do
    association :skin
    name { 'blank' }
    sequence(:alias) { |count| "Component #{count}" }
    place_holder { 'home' }
  end
end
