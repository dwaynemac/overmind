class CreateSyncRequest < ActiveRecord::Migration
  def change
    create_table :sync_requests do |t|
      t.integer :school_id
      t.integer :year

      t.string :state

      t.timestamps
    end
  end
end
