class Grouping < ActiveRecord::Base
  has_and_belongs_to_many :sites, order: 'name asc'

  validates :name, presence: true
end
