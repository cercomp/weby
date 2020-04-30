FactoryGirl.define do
  factory :user do
    sequence(:email) { |count| "email#{count}@email.com" }
    sequence(:login) { |count| "login#{count}" }
    first_name 'Name'
    last_name 'Surname'
    password 'Admin1'
    password_confirmation 'Admin1'
    is_admin true
    confirmed_at Time.current
  end
end
