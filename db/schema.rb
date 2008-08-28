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

ActiveRecord::Schema.define(:version => 1) do

  create_table "ip_range_imports", :force => true do |t|
    t.string  "country_code_3"
    t.string  "country_code_2"
    t.string  "country"
    t.integer "range_start",    :limit => 10, :precision => 10, :scale => 0
    t.integer "range_end",      :limit => 10, :precision => 10, :scale => 0
    t.string  "registry"
    t.date    "assigned_at"
  end

  add_index "ip_range_imports", ["range_start"], :name => "index_ip_range_imports_on_range_start"
  add_index "ip_range_imports", ["range_end"], :name => "index_ip_range_imports_on_range_end"

  create_table "ip_ranges", :force => true do |t|
    t.string  "country_code_3"
    t.string  "country_code_2"
    t.string  "country"
    t.integer "range_start",    :limit => 10, :precision => 10, :scale => 0
    t.integer "range_end",      :limit => 10, :precision => 10, :scale => 0
    t.string  "registry"
    t.date    "assigned_at"
  end

  add_index "ip_ranges", ["range_start"], :name => "index_ip_ranges_on_range_start"
  add_index "ip_ranges", ["range_end"], :name => "index_ip_ranges_on_range_end"

end
