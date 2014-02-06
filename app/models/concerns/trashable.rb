module Trashable
  extend ActiveSupport::Concern
      
  included do
    default_scope   where(deleted_at: nil)
    def self.trashed 
      unscoped.where("deleted_at is not null")
    end
  end
        
  def trash
    if deleted_at.nil?
      status = true
      if self.respond_to?(:check_page_status)
        status = self.check_page_status
      end
      if status
        update_attribute(:deleted_at, Time.now)
      else
        false
      end
    else
      destroy
    end
  end
end
