FactoryGirl.define do
  factory :banner do
    sequence(:title) { |count| "Banner #{count}" }
  end
end
