FactoryGirl.define do
  factory :image_repository, class: "Repository" do
    description "Image Description"
    archive File.new("#{Rails.root}/spec/factories/rails.png")
  end

  factory :pdf_repository, class: "Repository" do
    description "PDF Description"
    archive File.new("#{Rails.root}/spec/factories/rails.pdf")
  end
end

