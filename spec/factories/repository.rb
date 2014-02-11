FactoryGirl.define do
  factory :repository do
    sequence(:archive_file_name) { |count| "Arquivo#{count}" }
    description "Descrição"
  end
end
