module Weby
  class I18nsTemplate < ApplicationRecord
    self.abstract_class = true

    belongs_to :locale

    validates :locale_id,
              presence: true,
              numericality: true
  end
end
