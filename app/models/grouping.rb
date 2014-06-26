class Grouping < ActiveRecord::Base
  has_and_belongs_to_many :sites, -> { order(:name) }

  validates :name, presence: true

  scope :visible, -> { where(hidden: false) }
end
