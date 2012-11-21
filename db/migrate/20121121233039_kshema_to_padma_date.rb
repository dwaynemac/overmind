class KshemaToPadmaDate < ActiveRecord::Migration
  def change
    add_column :schools, :migrated_kshema_to_padma_at, :timestamp
  end
end
