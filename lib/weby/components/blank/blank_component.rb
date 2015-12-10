class BlankComponent < Component
  component_settings :body, :put_at_end

  def put_at_end?
	  put_at_end.blank? ? false : put_at_end.to_i == 1
  end

end
