class Extension < ApplicationRecord
  belongs_to :site

  validates :name, :site, presence: true
  validates :name, uniqueness: { scope: :site_id, message: :already_installed }

  after_find do
    extension = Weby.extensions[name.to_sym]
    extension.settings.each do |setting_name|
      class_eval do
        define_method(setting_name)       { settings[setting_name.to_s] }
        if setting_name.match(/^show_/)
          define_method("#{setting_name}?") { settings[setting_name.to_s].to_i == 1 }
        end
        define_method("#{setting_name}=") { |value| settings[setting_name.to_s] = value }
      end
    end if extension
  end

  def self.import(attrs, _options = {})
    return attrs.each { |attr| import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['extension'] if attrs.key? 'extension'

    return if Extension.unscoped.find_by_name(attrs['name'])

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', '@type', 'type')

    self.create!(attrs)
  end
end
