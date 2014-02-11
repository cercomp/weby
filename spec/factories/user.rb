FactoryGirl.define do
  factory :user do
    sequence(:email) { |count| "email#{count}@email.com" }
    sequence(:login) { |count| "login#{count}" }
    first_name 'Nome'
    last_name 'Sobrenome'
    password 'Admin1'
    password_confirmation 'Admin1'
    is_admin true
    # required if the Devise Confirmable module is used
    confirmed_at Time.now
  end
end
