class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :username
      t.string :full_name
      t.timestamps
    end

    create_table :schools_teachers do |t|
      t.integer :teacher_id
      t.integer :school_id
    end
  end
end
