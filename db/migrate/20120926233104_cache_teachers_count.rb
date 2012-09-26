class CacheTeachersCount < ActiveRecord::Migration
  def change
    add_column :schools, :last_teachers_count, :integer
  end
end
