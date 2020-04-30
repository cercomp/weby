module Trashable
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }

    def self.trashed
      result = unscoped.where('deleted_at is not null')
      if site_id = current_scope.where_values_hash['site_id']
        result = result.where(site_id: site_id)
      end
      result
    end

    define_model_callbacks :trash, :untrash
  end

  def is_trashed?
    !!deleted_at
  end

  def trash
    if deleted_at
      unscoped_destroy
    else
      run_callbacks :trash do
        update_attribute(:deleted_at, Time.current)
      end
    end
  end

  def untrash
    run_callbacks :untrash do
      update_attribute(:deleted_at, nil)
    end
  end
end
