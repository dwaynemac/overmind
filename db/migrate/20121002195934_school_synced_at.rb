class SchoolSyncedAt < ActiveRecord::Migration
  def change
    add_column :schools, :synced_at, :timestamp
  end
end
