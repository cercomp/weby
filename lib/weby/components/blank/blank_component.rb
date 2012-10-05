class BlankComponent < Component
  component_settings :body, :visibility

  validates :body, presence: true

  alias :_visibility :visibility
  def visibility
    _visibility.blank? ? 0 : _visibility.to_i
  end

end
