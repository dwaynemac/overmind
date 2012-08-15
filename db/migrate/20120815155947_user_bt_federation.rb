class UserBtFederation < ActiveRecord::Migration
  def change
    add_column :users, :federation_id, :integer
  end
end
