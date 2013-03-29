class AddTypeToMonthlyStat < ActiveRecord::Migration
  def up
    add_column :monthly_stats, :type, :string
    MonthlyStat.update_all(type: 'SchoolMonthlyStat')
  end

  def down
    remove_column :monthly_stats, :type
  end
end
