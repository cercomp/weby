class FeedbackComponent < Component
  component_settings :label, :groups_id

  i18n_settings :label

  validate :label_present

  alias_method :_groups_id, :groups_id
  def groups_id
    _groups_id.blank? ? '' : _groups_id
  end

  def parse_groups(site)
    if groups_id.include? ''
      nil
    else
      groups_site = Feedback::Group.where(site_id: site.id)
      ''.tap do |group_names|
        groups_site.each do |group|
          group_names << group.name + ',' if groups_id.include? group.id.to_s
        end
      end
    end
  end

  def checked?(id)
    groups_id.include? id.to_s
  end

  def default_alias
    label
  end

  private

  def label_present
    errors.add(:label, :blank) if label.blank?
  end
end
