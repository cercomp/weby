class Locale < ApplicationRecord
  has_many :news, class_name: 'Page::I18ns'

  has_and_belongs_to_many :sites

  def to_s
    name
  end

  def self.import(attrs, _options = {})
    return attrs.each { |attr| import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['locales'] if attrs.key? 'locales'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

    self.create!(attrs)
  end

  def code
    (name.match('-') ? name.split('-')[1] : name).titleize
  end
end
