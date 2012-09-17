class CacheLastStudentsCount < ActiveRecord::Migration
  def change
    add_column :schools, :last_students_count, :integer
  end
end
