class AddPriority < ActiveRecord::Migration
  def change
    add_column :sync_requests, :priority, :integer
  end
end
