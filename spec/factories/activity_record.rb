FactoryGirl.define do
  factory :activity_record do
    sequence(:loggeable_id) { |count| "#{count}" }
    sequence(:loggeable_type) { |count| "Type #{count}" }
  end
end
