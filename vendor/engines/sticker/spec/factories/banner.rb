FactoryGirl.define do
  factory :sticker_banner do
    sequence(:title) { |count| "Banner #{count}" }
  end
end
