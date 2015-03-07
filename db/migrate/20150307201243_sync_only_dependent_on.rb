class SyncOnlyDependentOn < ActiveRecord::Migration
  def change
    add_column :sync_requests, :filter_by_event, :string
  end
end
