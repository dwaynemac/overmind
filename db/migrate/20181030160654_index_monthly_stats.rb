class IndexMonthlyStats < ActiveRecord::Migration
  def change
    add_index "monthly_stats", ["id","school_id","teacher_id","ref_date"], name: "existance_optimizer"
    add_index "monthly_stats", ["school_id","name","teacher_id","ref_date"], name: "load_optimizer"

    add_index "schools", "federation_id"
    add_index "schools", "account_name"
    add_index "schools", "id"
    add_index "schools", "nucleo_id"

  end
end
