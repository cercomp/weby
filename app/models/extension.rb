class Extension < ActiveRecord::Base
  self.table_name = 'extension_sites'

  belongs_to :site

  validates :name, presence: true, uniqueness: { scope: :site_id, message: :already_installed }
  validates :site, presence: true

  def self.import attrs, options={}
    return attrs.each{ |attr| self.import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['extensions'] if attrs.has_key? 'extensions'

    return if Extension.unscoped.find_by_name(attrs['name'])

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

    self.create!(attrs)
  end
end
