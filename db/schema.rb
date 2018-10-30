# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20181030160654) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "federations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "nucleo_id"
  end

  create_table "monthly_stats", :force => true do |t|
    t.date     "ref_date"
    t.integer  "school_id"
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "service"
    t.integer  "teacher_id"
    t.string   "type"
    t.string   "unit"
  end

  add_index "monthly_stats", ["id", "school_id", "teacher_id", "ref_date"], :name => "existance_optimizer"
  add_index "monthly_stats", ["school_id", "name", "teacher_id", "ref_date"], :name => "load_optimizer"

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.integer  "federation_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "nucleo_id"
    t.integer  "last_students_count"
    t.string   "account_name"
    t.integer  "last_teachers_count"
    t.datetime "synced_at"
    t.datetime "migrated_kshema_to_padma_at"
    t.integer  "count_students_relative_to_value"
    t.date     "count_students_relative_to_date"
    t.boolean  "cached_nucleo_enabled"
    t.boolean  "cached_padma_enabled"
  end

  add_index "schools", ["account_name"], :name => "index_schools_on_account_name"
  add_index "schools", ["federation_id"], :name => "index_schools_on_federation_id"
  add_index "schools", ["id"], :name => "index_schools_on_id"
  add_index "schools", ["nucleo_id"], :name => "index_schools_on_nucleo_id"

  create_table "schools_teachers", :force => true do |t|
    t.integer "teacher_id"
    t.integer "school_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sync_requests", :force => true do |t|
    t.integer  "school_id"
    t.integer  "year"
    t.string   "state"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "priority"
    t.integer  "month"
    t.string   "filter_by_event"
  end

  create_table "teachers", :force => true do |t|
    t.string   "username"
    t.string   "full_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "federation_id"
    t.string   "role"
    t.string   "locale"
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
