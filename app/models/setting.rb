class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates :name, :value, presence: true
  attr_accessor :default_value

  VALUES_SET = {login_protocol: %w(http https),
    per_page_default: :numericality,
    tld_length: :numericality}

  validate :check_value
  def check_value
    if (pattern = VALUES_SET[name.to_sym])
      case pattern
      when Array
        errors.add(:value, :invalid_format, format_message: "#{name} = [#{pattern.join(",")}]") unless pattern.include?(value)
      when Symbol
        validator = "ActiveModel::Validations::#{pattern.to_s.classify}Validator".constantize.new(attributes: :value)
        validator.validate self
      else
        errors.add(:value, :invalid_format, format_message: "#{name} = #{pattern}") unless value.match(pattern)
      end
    end
  end

  #TODO change this to a common place for all models (if needed)
  def self.new_or_update attributes
    instance = Setting.find_by_id attributes.delete(:id)
    if instance
      instance.assign_attributes attributes
    else 
      instance = self.new(attributes)
    end
    instance
  end
end
