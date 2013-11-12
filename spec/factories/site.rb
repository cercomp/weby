FactoryGirl.define do
  factory :site do
    sequence(:name) { |count| "site#{count}" }
    sequence(:url) { |count| "http://site#{count}.lvh.me" }
    sequence(:title) { |count| "Site #{count}" }
    theme 'this2'
  end
end
