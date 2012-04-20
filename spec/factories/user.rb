FactoryGirl.define do
  sequence(:email){ |count| "email#{count}@email.com" }
  sequence(:login){ |count| "Login#{count}" }

  factory :user do
    email { FactoryGirl.generate(:email) }
    login { FactoryGirl.generate(:login) }
    first_name 'first name'
    last_name 'last name'
    password 'Admin1'
    password_confirmation 'Admin1'
  end
end
