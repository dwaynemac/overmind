class CachePadmaEnabled < ActiveRecord::Migration
  def change
    add_column :schools, :cached_padma_enabled, :boolean
  end
end
