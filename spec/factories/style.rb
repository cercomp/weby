FactoryGirl.define do
  factory :style do
    sequence(:name) { |count| "Estilo #{count}" }
  end
end

