FactoryGirl.define do
  factory :page do
    date_begin_at Time.now
    association :site
    association :author, factory: :user
  end
end
