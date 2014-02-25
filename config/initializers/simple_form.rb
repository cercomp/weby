#TODO keep this file updated
inputs = %w[
  CollectionSelectInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]

inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize

  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end

  Object.const_set(input_type, new_class)
end

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.boolean_style = :nested

  config.wrappers :append, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label,  class: 'col-md-2 control-label'
    b.wrapper tag: 'div', class: ' col-md-7' do |append|
      append.use :input, wrap_with: { tag: 'div', class: 'input-group' }
    end
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end

  config.wrappers :checkbox, tag: :div, class: "checkbox", error_class: "has-error" do |b|
    b.use :html5
    b.wrapper tag: :label do |ba|
      ba.use :input
      ba.use :label_text, wrap_with: { class: 'col-md-12' }
    end
    b.use :hint,  wrap_with: { tag: :p, class: " help-block" }
    b.use :error, wrap_with: { tag: :span, class: "help-block text-danger" }
  end

  config.wrappers :devise_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    b.optional :pattern
    b.optional :readonly
    b.use :error, wrap_with: { tag: 'p', class: 'help-block has-error' }
    b.use :input
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :devise_checkbox, tag: 'div', class: 'checkbox' do |b|
    b.use :html5
    b.wrapper tag: :label do |ba|
      ba.use :input
      ba.use :label_text
    end
  end

  config.wrappers :bootstrap3, tag: 'div', class: 'form-group', error_class: 'has-error',
                  defaults: { input_html: { class: 'form-group default_class' } } do |b|
    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    b.optional :pattern
    b.optional :readonly
    b.use :label,  class: 'col-md-2 control-label'
    b.wrapper tag: 'div', class: 'col-md-7' do |input_block|
      input_block.use :input
      input_block.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    end
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com/)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap3

  # Default class for buttons
  config.button_class = 'btn'

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'alert alert-danger'
end
