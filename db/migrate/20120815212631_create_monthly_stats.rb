class CreateMonthlyStats < ActiveRecord::Migration
  def change
    create_table :monthly_stats do |t|
      t.date :ref_date
      t.references :school
      t.string :name
      t.integer :value
      t.timestamps
    end
  end
end
