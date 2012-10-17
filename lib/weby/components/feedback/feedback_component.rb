class FeedbackComponent < Component
  component_settings :label, :groups_id 

  validates :label, presence: true

  alias :_groups_id :groups_id
  def groups_id
    _groups_id.blank? ? "" : _groups_id
  end

  def parse_groups(site)
    groups_site = site.groups 
    "".tap do |group_names|
      groups_site.each do |group|
        group_names << group.name + "," if groups_id.include? group.id.to_s
      end
    end
  end

  def checked?(id)
    groups_id.include? id.to_s
  end

end
