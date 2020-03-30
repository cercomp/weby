class CollectionInput < SimpleForm::Inputs::CollectionInput
  def input(wrapper_options)
    super << "#{options[:paginate]}".html_safe
  end
end
