FactoryGirl.define do
  factory :sites_menu do
    sequence(:category) { |count| "Categoria#{count}"}
  end
end
