FactoryGirl.define do
  factory :component do
    place_holder 'home'
    publish 'true'
    sequence('alias') { |count| "Component#{count}" }
  end
end
