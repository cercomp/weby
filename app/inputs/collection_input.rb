class CollectionInput < SimpleForm::Inputs::CollectionInput
  def input
    super << "#{options[:paginate]}".html_safe
  end
end
