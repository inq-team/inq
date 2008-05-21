# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 9) do

  create_table "audits", :force => true do |t|
    t.binary   "comparison"
    t.integer  "testing_id"
    t.integer  "confirmation"
    t.datetime "confirmation_date"
    t.integer  "person_id"
    t.text     "comment"
  end

  create_table "component_groups", :force => true do |t|
    t.string  "name",     :limit => 50
    t.string  "info",     :limit => 60
    t.integer "isactive", :limit => 6,  :default => 1, :null => false
  end

  create_table "component_models", :force => true do |t|
    t.string  "vendor",             :limit => 128
    t.string  "name",               :limit => 128
    t.integer "component_group_id"
    t.string  "short_name",         :limit => 70
    t.integer "isactive",           :limit => 6,   :default => 1, :null => false
  end

  add_index "component_models", ["vendor"], :name => "vendor"

  create_table "components", :force => true do |t|
    t.integer "testing_id"
    t.integer "component_model_id"
    t.integer "hw_qty",             :limit => 6
    t.string  "serial",             :limit => 64
  end

  create_table "computer_stages", :force => true do |t|
    t.integer  "computer_id",                               :null => false
    t.string   "stage",       :limit => 64, :default => "", :null => false
    t.datetime "start"
    t.datetime "end"
    t.integer  "person_id"
    t.text     "comment"
  end

  create_table "computers", :force => true do |t|
    t.integer  "model_id"
    t.integer  "customer_id"
    t.integer  "tester_id",    :limit => 20, :default => 1
    t.integer  "assembler_id", :limit => 20, :default => 1
    t.string   "shelf",        :limit => 8
    t.string   "doc_no",       :limit => 10
    t.integer  "order_id"
    t.datetime "last_ping"
    t.string   "ip",           :limit => 20
    t.integer  "profile_id"
  end

  create_table "customers", :force => true do |t|
    t.string  "name",     :limit => 60
    t.string  "info",     :limit => 100
    t.integer "isactive", :limit => 6,   :default => 1, :null => false
  end

  create_table "firmwares", :force => true do |t|
    t.string  "version",            :null => false
    t.string  "image",              :null => false
    t.integer "component_model_id", :null => false
  end

  create_table "graphs", :force => true do |t|
    t.integer  "testing_id"
    t.integer  "monitoring_id"
    t.datetime "timestamp"
    t.integer  "key"
    t.float    "value"
  end

  create_table "log_data", :id => false, :force => true do |t|
    t.integer  "log_id"
    t.datetime "log_time"
    t.string   "log_text",  :limit => 250
    t.string   "log_cat",   :limit => 250
    t.integer  "log_level",                :default => 0
  end

  create_table "macs", :id => false, :force => true do |t|
    t.integer "current_id"
    t.string  "mac",        :limit => 250
  end

  create_table "marks", :force => true do |t|
    t.integer "testing_stage_id",                                :null => false
    t.string  "key",              :limit => 250, :default => "", :null => false
    t.float   "value_float"
    t.text    "value_str"
  end

  create_table "mb_bios", :id => false, :force => true do |t|
    t.integer "hw_id"
    t.string  "bios",  :limit => 250
    t.string  "use",   :limit => 250
  end

  create_table "models", :force => true do |t|
    t.string  "name",     :limit => 250
    t.string  "stages",   :limit => 250, :default => "mb_bios raid_bios test memtest stress server dmi"
    t.string  "dmi_name", :limit => 250, :default => "",                                                 :null => false
    t.integer "ismodel",  :limit => 6,   :default => 1
    t.integer "mask",     :limit => 6,   :default => 0,                                                  :null => false
  end

  add_index "models", ["name"], :name => "name"
  add_index "models", ["name"], :name => "ft_models"

  create_table "order_lines", :force => true do |t|
    t.integer "order_id",                                :null => false
    t.string  "name",     :limit => 250, :default => "", :null => false
    t.integer "qty",                                     :null => false
  end

  add_index "order_lines", ["order_id"], :name => "order_id"

  create_table "order_stages", :force => true do |t|
    t.integer  "order_id",                                :null => false
    t.string   "stage",     :limit => 64, :default => "", :null => false
    t.datetime "start"
    t.datetime "end"
    t.integer  "person_id"
    t.text     "comment"
  end

  add_index "order_stages", ["order_id"], :name => "order_id"
  add_index "order_stages", ["order_id", "stage"], :name => "order_id_2"

  create_table "orders", :force => true do |t|
    t.string "buyer_order_number", :limit => 64
    t.string "mfg_task_number",    :limit => 64
    t.string "mfg_report_number",  :limit => 64
    t.string "customer",           :limit => 250
    t.string "title",              :limit => 250
  end

  create_table "people", :force => true do |t|
    t.string  "login",        :limit => 32
    t.string  "name",         :limit => 128
    t.boolean "is_tester",                   :default => false, :null => false
    t.boolean "is_assembler",                                   :null => false
    t.string  "password",     :limit => 40
    t.boolean "is_student",                                     :null => false
  end

  create_table "person_times", :force => true do |t|
    t.integer  "person_id",                :null => false
    t.integer  "shift_id",                 :null => false
    t.datetime "start"
    t.datetime "finish"
    t.string   "comment",   :limit => 128
  end

  add_index "person_times", ["person_id"], :name => "person_id"
  add_index "person_times", ["shift_id"], :name => "shift_id"

  create_table "profiles", :force => true do |t|
    t.text     "xml"
    t.integer  "model_id"
    t.integer  "computer_id"
    t.string   "feature",     :limit => 64
    t.datetime "timestamp",                 :null => false
  end

  create_table "raid_bios", :id => false, :force => true do |t|
    t.integer "hw_id"
    t.string  "bios",  :limit => 250
    t.string  "use",   :limit => 250
  end

  create_table "servers_params", :id => false, :force => true do |t|
    t.integer "param_value", :limit => 20
    t.integer "unisrv_id"
    t.integer "param_id"
  end

  create_table "shifts", :force => true do |t|
    t.date    "date",                             :null => false
    t.integer "kind", :limit => 4, :default => 0, :null => false
    t.integer "open", :limit => 4, :default => 1, :null => false
  end

  add_index "shifts", ["date"], :name => "date"
  add_index "shifts", ["open"], :name => "open"

  create_table "stages", :primary_key => "stage_id", :force => true do |t|
    t.string  "stage_name", :limit => 250
    t.string  "stage_desc", :limit => 250
    t.integer "model_id"
    t.string  "stage_text", :limit => 40
  end

  create_table "testing_stages", :force => true do |t|
    t.integer  "testing_id",                              :null => false
    t.string   "stage",      :limit => 64
    t.datetime "start"
    t.datetime "end"
    t.integer  "result",                   :default => 0, :null => false
    t.text     "comment",                                 :null => false
  end

  add_index "testing_stages", ["id"], :name => "id", :unique => true
  add_index "testing_stages", ["testing_id"], :name => "testing_id"
  add_index "testing_stages", ["testing_id", "start"], :name => "testing_id_2"

  create_table "testings", :force => true do |t|
    t.integer  "computer_id",            :null => false
    t.datetime "test_start"
    t.datetime "test_end"
    t.integer  "profile_id"
    t.float    "progress_complete"
    t.float    "progress_total"
    t.text     "custom_sticker"
    t.integer  "progress_promised_time"
  end

end
