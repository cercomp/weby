class FixEventTypes < ActiveRecord::Migration
  def up
    Page.where(kind: 'nacional' ).update_all("kind = 'national'")
    Page.where(kind: 'internacional' ).update_all("kind = 'international'")
  end

  def down
    Page.where(kind: 'national' ).update_all("kind = 'nacional'")
    Page.where(kind: 'international' ).update_all("kind = 'internacional'")
  end
end
