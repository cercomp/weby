module Weby
  class I18ns < ActiveRecord::Base
    self.abstract_class = true

    belongs_to :locale

    validates :locale_id,
      presence: true,
      numericality: true
  end
end