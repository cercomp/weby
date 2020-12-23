class Setting < ApplicationRecord
  attr_accessor :default_value

  VALUES_SET = {
    login_protocol: %w(http https),
    per_page_default: :numericality,
    tld_length: :numericality,
    maintenance_mode: %w(false true),
    ldaps: %w(false true),
    force_ldap_login: %w(false true),
    facebook_comments: %w(false true),
    accessibility_text: {text: true}
  }

  validates :name, :value, presence: true
  validates :name, uniqueness: true

  validate :check_value

  def check_value
    if (pattern = VALUES_SET[name.to_sym])
      case pattern
      when Hash
        if pattern[:select]
          values = pattern[:select].map { |a| a.is_a?(Array) ? a[1].to_s : a.to_s }
          invvalue = false
          value.split(',').each do |each_value|
            invvalue = true unless values.include?(each_value)
          end if value
          errors.add(:value, :invalid_format, format_message: "#{name} = [#{pattern[:select].map { |a| a.is_a?(Array) ? a[0] : a }.join(',')}]") if invvalue
        elsif pattern[:text]
          #no validations yet
        else
          # TODO another kind of input
        end
      when Array
        values = pattern.map { |a| a.is_a?(Array) ? a[1].to_s : a.to_s }
        errors.add(:value, :invalid_format, format_message: "#{name} = [#{pattern.map { |a| a.is_a?(Array) ? a[0] : a }.join(',')}]") unless values.include?(value)
      when Symbol
        validator = "ActiveModel::Validations::#{pattern.to_s.classify}Validator".constantize.new(attributes: :value)
        validator.validate self
      else
        errors.add(:value, :invalid_format, format_message: "#{name} = #{pattern}") unless value.match(pattern)
      end
    end
  end

  # TODO change this to a common place for all models (if needed)
  def self.new_or_update(attributes)
    instance = Setting.find_by(id: attributes.delete(:id))
    attributes.each { |k, v| attributes[k] = v.join(',') if v.is_a?(Array) }
    if instance
      instance.assign_attributes attributes
    else
      instance = new(attributes)
    end
    instance
  end
end
