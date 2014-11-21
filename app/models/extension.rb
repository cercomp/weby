class Extension < ActiveRecord::Base
  include RailsSettings::Extend

  belongs_to :site

  validates :name, :site, presence: true
  validates :name, uniqueness: { scope: :site_id, message: :already_installed }

  after_find do
    extension = Weby.extensions[name.to_sym]
    extension.settings.each do |setting_name|
      class_eval do
        define_method(setting_name)       { settings.send(setting_name) }
        define_method("#{setting_name}=") { |value| settings.send("#{setting_name}=", value) }
      end
    end if extension
  end

  def self.import(attrs, _options = {})
    return attrs.each { |attr| import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['extension'] if attrs.key? 'extension'

    return if Extension.unscoped.find_by_name(attrs['name'])

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

    self.create!(attrs)
  end
end
