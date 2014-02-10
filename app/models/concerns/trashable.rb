module Trashable
  extend ActiveSupport::Concern
      
  included do
    default_scope where(deleted_at: nil)
    def self.trashed 
      unscoped.where("deleted_at is not null")
    end
  end
        
  def trash
    if deleted_at
      destroy
    else
      if (respond_to?(:before_trash, true) ? before_trash : true)
        update_attribute(:deleted_at, Time.now)
      else
        false
      end
    end
  end
end
