FactoryGirl.define do
  factory :page do
    sequence(:title) { |count| "Título#{count}" }
    text "Texto"
  end
end
