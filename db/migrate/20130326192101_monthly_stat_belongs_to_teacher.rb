class MonthlyStatBelongsToTeacher < ActiveRecord::Migration
  def change
    add_column :monthly_stats, :teacher_id, :integer, default: nil
  end
end
