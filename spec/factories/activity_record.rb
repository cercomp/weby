FactoryBot.define do
  factory :activity_record do
    association :user
    browser { 'Browser' }
    ip_address { '127.0.0.1' }
    controller { 'Controller' }
    action { 'Action' }
    params { 'Params' }
    note { 'Note' }
  end
end
