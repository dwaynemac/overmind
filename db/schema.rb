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

ActiveRecord::Schema.define(:version => 20140820221146) do

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
  end

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
  end

  create_table "schools_teachers", :force => true do |t|
    t.integer "teacher_id"
    t.integer "school_id"
  end

  create_table "sync_requests", :force => true do |t|
    t.integer  "school_id"
    t.integer  "year"
    t.string   "state"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "synced_upto"
    t.integer  "priority"
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
