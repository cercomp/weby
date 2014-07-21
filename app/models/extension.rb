class Extension < ActiveRecord::Base
  # TODO rename table extension_sites to extensions
  self.table_name = 'extension_sites'
  include RailsSettings::Extend

  belongs_to :site

  validates :name, :site, presence: true
  validates :name, uniqueness: { scope: :site_id, message: :already_installed }

  after_find do
    Weby.extensions[name.to_sym].settings.each do |setting_name|
      class_eval do
        define_method(setting_name)       { self.settings.send(setting_name) }
        define_method("#{setting_name}=") { |value| self.settings.send("#{setting_name}=", value) }
      end
    end
  end

  def self.import(attrs, _options = {})
    return attrs.each { |attr| import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['extensions'] if attrs.key? 'extensions'

    return if Extension.unscoped.find_by_name(attrs['name'])

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

    self.create!(attrs)
  end
end
