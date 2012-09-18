class AddAccountNameToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :account_name, :string
  end
end
