class AddUnit < ActiveRecord::Migration
  def change
    add_column :monthly_stats, :unit, :string
  end
end
