FactoryGirl.define do
  factory :site do
    sequence(:name) { |count| "Site#{count}" }
    url 'http://localhost.com'
  end
end
