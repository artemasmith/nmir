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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140718054510) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "advertisments", force: true do |t|
    t.integer  "offer_type",                                                        null: false
    t.integer  "property_type",                                                     null: false
    t.integer  "category",                                                          null: false
    t.integer  "agent_category"
    t.integer  "currency"
    t.integer  "distance"
    t.integer  "time_on_transport"
    t.integer  "time_on_foot"
    t.integer  "agency_id"
    t.integer  "floor_from"
    t.integer  "floor_to"
    t.integer  "floor_cnt_from"
    t.integer  "floor_cnt_to"
    t.datetime "expire_date"
    t.boolean  "payed_adv",                                         default: false
    t.boolean  "manually_added"
    t.boolean  "not_for_agents"
    t.boolean  "mortgage",                                          default: false
    t.string   "name"
    t.string   "sales_agent"
    t.string   "phone"
    t.string   "organization"
    t.string   "space_unit"
    t.decimal  "outdoors_space_from",      precision: 15, scale: 2
    t.decimal  "outdoors_space_to",        precision: 15, scale: 2
    t.string   "outdoors_space_unit"
    t.integer  "price_from"
    t.integer  "price_to"
    t.decimal  "unit_price_from",          precision: 15, scale: 2
    t.decimal  "unit_price_to",            precision: 15, scale: 2
    t.integer  "outdoors_unit_price_from"
    t.integer  "outdoors_unit_price_to"
    t.decimal  "space_from",               precision: 15, scale: 2
    t.decimal  "space_to",                 precision: 15, scale: 2
    t.text     "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "landmark"
    t.text     "comment"
    t.text     "private_comment"
    t.integer  "adv_type"
    t.integer  "region_id"
    t.integer  "district_id"
    t.integer  "city_id"
    t.integer  "admin_area_id"
    t.integer  "non_admin_area_id"
    t.integer  "street_id"
    t.integer  "address_id"
    t.integer  "landmark_id"
    t.integer  "room_from"
    t.integer  "room_to"
  end

  create_table "locations", force: true do |t|
    t.string  "title"
    t.string  "translit"
    t.integer "location_type"
    t.integer "location_id"
  end

  add_index "locations", ["location_id"], name: "index_locations_on_location_id", using: :btree
  add_index "locations", ["location_type"], name: "index_locations_on_location_type", using: :btree

  create_table "neighborhoods", force: true do |t|
    t.integer "location_id"
    t.integer "neighbor_id"
  end

  add_index "neighborhoods", ["location_id", "neighbor_id"], name: "by_location_neighbor", using: :btree

  create_table "phones", force: true do |t|
    t.string  "number"
    t.string  "original"
    t.integer "user_id"
  end

  add_index "phones", ["user_id"], name: "index_phones_on_user_id", using: :btree

  create_table "sections", force: true do |t|
    t.integer "advertisments_count", default: 0
    t.string  "url"
    t.text    "description"
    t.text    "keywords"
    t.text    "p"
    t.string  "title"
    t.string  "h1"
    t.string  "h2"
    t.string  "h3"
    t.integer "location_id"
    t.integer "offer_type"
    t.integer "category"
    t.integer "property_type"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "blocked",                default: false
    t.boolean  "from_admin",             default: false
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
