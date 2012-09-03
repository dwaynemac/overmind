class AddNucleoId < ActiveRecord::Migration
  def change
    add_column :schools, :nucleo_id, :integer
    add_column :federations, :nucleo_id, :integer
  end
end
