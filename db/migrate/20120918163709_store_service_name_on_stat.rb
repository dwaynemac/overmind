class StoreServiceNameOnStat < ActiveRecord::Migration
  def change
    add_column :monthly_stats, :service, :string
  end
end
