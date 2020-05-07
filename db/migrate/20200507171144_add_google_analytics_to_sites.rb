class AddGoogleAnalyticsToSites < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :google_analytics, :string
  end
end
