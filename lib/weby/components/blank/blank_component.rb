class BlankComponent < Component
  component_settings :body, :put_at_end, :html_class

  i18n_settings :body

  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }

  def put_at_end?
	  put_at_end.blank? ? false : put_at_end.to_i == 1
  end

end
