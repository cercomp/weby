FactoryGirl.define do
  factory :menu do
    sequence(:name) { |count| "Menu #{count}" }
  end
end
