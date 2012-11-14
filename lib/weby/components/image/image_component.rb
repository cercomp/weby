class ImageComponent < Component
  component_settings :repository_id, :size, :height, :width, :target_type, :target_id, :url, :new_tab

  alias :_new_tab :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  validates :repository_id, presence: true
  
  belongs_to :target, polymorphic: true
end
