class AddRelativeStudentCount < ActiveRecord::Migration
  def change
    add_column :schools, :count_students_relative_to_value, :integer
    add_column :schools, :count_students_relative_to_date, :date
  end
end
