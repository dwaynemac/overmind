class SyncRequestMonth < ActiveRecord::Migration
  def up
    add_column :sync_requests, :month, :integer
    remove_column :sync_requests, :synced_upto
  end

  def down
    add_column :sync_requests, :synced_upto, :integer
    remove_column :sync_requests, :month
  end
end
