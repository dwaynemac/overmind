class CacheNucleoStatus < ActiveRecord::Migration
  def change
    add_column :schools, :cached_nucleo_enabled, :boolean
  end
end
