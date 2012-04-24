FactoryGirl.define do
  values = %w[pt-BR en es uk]
  factory :locale do
    sequence(:name) { |count| values[ count % values.length ] }
  end
end

