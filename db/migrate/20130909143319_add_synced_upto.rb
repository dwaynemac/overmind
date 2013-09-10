class AddSyncedUpto < ActiveRecord::Migration
  def change
    add_column :sync_requests, :synced_upto, :integer
  end
end
