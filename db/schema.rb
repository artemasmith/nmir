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

ActiveRecord::Schema.define(version: 20150427210307) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ADDROBJ", force: true do |t|
    t.integer "actstatus"
    t.string  "aoguid",     limit: 36
    t.string  "aoid",       limit: 36
    t.integer "aolevel"
    t.string  "areacode",   limit: 3
    t.string  "autocode",   limit: 1
    t.integer "centstatus"
    t.string  "citycode",   limit: 3
    t.string  "code",       limit: 17
    t.integer "currstatus"
    t.date    "enddate"
    t.string  "formalname", limit: 120
    t.string  "ifnsfl",     limit: 4
    t.string  "ifnsul",     limit: 4
    t.string  "nextid",     limit: 36
    t.string  "offname",    limit: 120
    t.string  "okato",      limit: 11
    t.string  "oktmo",      limit: 8
    t.integer "operstatus"
    t.string  "parentguid", limit: 36
    t.string  "placecode",  limit: 3
    t.string  "plaincode",  limit: 15
    t.string  "postalcode", limit: 6
    t.string  "previd",     limit: 36
    t.string  "regioncode", limit: 2
    t.string  "shortname",  limit: 10
    t.date    "startdate"
    t.string  "streetcode", limit: 4
    t.string  "terrifnsfl", limit: 4
    t.string  "terrifnsul", limit: 4
    t.date    "updatedate"
    t.string  "ctarcode",   limit: 3
    t.string  "extrcode",   limit: 4
    t.string  "sextcode",   limit: 3
    t.integer "livestatus"
    t.string  "normdoc",    limit: 36
  end

  create_table "HOUSE01", force: true do |t|
    t.string  "aoguid",     limit: 36
    t.string  "buildnum",   limit: 10
    t.date    "enddate"
    t.integer "eststatus"
    t.string  "houseguid",  limit: 36
    t.string  "houseid",    limit: 36
    t.string  "housenum",   limit: 10
    t.integer "statstatus"
    t.string  "ifnsfl",     limit: 4
    t.string  "ifnsul",     limit: 4
    t.string  "okato",      limit: 11
    t.string  "oktmo",      limit: 8
    t.string  "postalcode", limit: 6
    t.date    "startdate"
    t.string  "strucnum",   limit: 10
    t.integer "strstatus"
    t.string  "terrifnsfl", limit: 4
    t.string  "terrifnsul", limit: 4
    t.date    "updatedate"
    t.string  "normdoc",    limit: 36
    t.integer "counter"
  end

  create_table "HOUSE02", force: true do |t|
    t.string  "aoguid",     limit: 36
    t.string  "buildnum",   limit: 10
    t.date    "enddate"
    t.integer "eststatus"
    t.string  "houseguid",  limit: 36
    t.string  "houseid",    limit: 36
    t.string  "housenum",   limit: 10
    t.integer "statstatus"
    t.string  "ifnsfl",     limit: 4
    t.string  "ifnsul",     limit: 4
    t.string  "okato",      limit: 11
    t.string  "oktmo",      limit: 8
    t.string  "postalcode", limit: 6
    t.date    "startdate"
    t.string  "strucnum",   limit: 10
    t.integer "strstatus"
    t.string  "terrifnsfl", limit: 4
    t.string  "terrifnsul", limit: 4
    t.date    "updatedate"
    t.string  "normdoc",    limit: 36
    t.integer "counter"
  end

  create_table "HOUSE61", force: true do |t|
    t.string  "aoguid",     limit: 36
    t.string  "buildnum",   limit: 10
    t.date    "enddate"
    t.integer "eststatus"
    t.string  "houseguid",  limit: 36
    t.string  "houseid",    limit: 36
    t.string  "housenum",   limit: 10
    t.integer "statstatus"
    t.string  "ifnsfl",     limit: 4
    t.string  "ifnsul",     limit: 4
    t.string  "okato",      limit: 11
    t.string  "oktmo",      limit: 8
    t.string  "postalcode", limit: 6
    t.date    "startdate"
    t.string  "strucnum",   limit: 10
    t.integer "strstatus"
    t.string  "terrifnsfl", limit: 4
    t.string  "terrifnsul", limit: 4
    t.date    "updatedate"
    t.string  "normdoc",    limit: 36
    t.integer "counter"
  end

  create_table "abuses", force: true do |t|
    t.integer  "advertisement_id"
    t.string   "comment"
    t.integer  "user_id"
    t.integer  "abuse_type"
    t.integer  "status",            default: 0
    t.string   "moderator_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "abuses", ["advertisement_id"], name: "index_abuses_on_advertisement_id", using: :btree

  create_table "advertisement_counters", force: true do |t|
    t.integer  "advertisement_id"
    t.integer  "counter_type"
    t.integer  "count",            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advertisement_counters", ["advertisement_id"], name: "index_advertisement_counters_on_advertisement_id", using: :btree

  create_table "advertisement_locations", force: true do |t|
    t.integer "advertisement_id"
    t.integer "location_id"
  end

  add_index "advertisement_locations", ["advertisement_id"], name: "index_advertisement_location_on_advertisement_id", using: :btree
  add_index "advertisement_locations", ["location_id"], name: "index_advertisement_location_on_location_id", using: :btree

  create_table "advertisements", force: true do |t|
    t.integer  "offer_type",                                                                  null: false
    t.integer  "property_type",                                                               null: false
    t.integer  "category",                                                                    null: false
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
    t.boolean  "payed_adv",                                                   default: false
    t.boolean  "manually_added"
    t.boolean  "not_for_agents"
    t.boolean  "mortgage",                                                    default: false
    t.string   "name"
    t.string   "sales_agent"
    t.string   "phone"
    t.string   "organization"
    t.decimal  "outdoors_space_from",                precision: 15, scale: 2
    t.decimal  "outdoors_space_to",                  precision: 15, scale: 2
    t.integer  "price_from",               limit: 8
    t.integer  "price_to",                 limit: 8
    t.decimal  "unit_price_from",                    precision: 15, scale: 2
    t.decimal  "unit_price_to",                      precision: 15, scale: 2
    t.integer  "outdoors_unit_price_from"
    t.integer  "outdoors_unit_price_to"
    t.decimal  "space_from",                         precision: 15, scale: 2
    t.decimal  "space_to",                           precision: 15, scale: 2
    t.text     "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "adv_type"
    t.integer  "room_from"
    t.integer  "room_to"
    t.integer  "status_type",                                                 default: 0,     null: false
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "locations_title"
    t.string   "landmark"
    t.boolean  "delta",                                                       default: true,  null: false
    t.text     "description"
    t.text     "p"
    t.string   "title"
    t.string   "h1"
    t.string   "h2"
    t.string   "h3"
    t.string   "url"
    t.string   "anchor"
    t.string   "preview_url"
    t.string   "preview_alt"
    t.integer  "user_role"
    t.integer  "zoom",                                                        default: 12,    null: false
    t.integer  "source",                                                      default: 0
  end

  add_index "advertisements", ["offer_type", "category", "property_type", "status_type"], name: "index_advertisements_on_ot_c_li_pt_st", using: :btree
  add_index "advertisements", ["status_type"], name: "index_advertisements_on_status_type", using: :btree

  create_table "deleted_advertisements", force: true do |t|
    t.integer "advertisement_id"
    t.integer "section_id"
  end

  add_index "deleted_advertisements", ["advertisement_id"], name: "index_deleted_advertisements_on_advertisement_id", using: :btree

  create_table "locations", force: true do |t|
    t.string  "title"
    t.string  "translit"
    t.integer "location_type"
    t.integer "location_id"
    t.integer "children_count",    default: 0
    t.string  "aoguid"
    t.string  "parentguid"
    t.integer "admin_area_id"
    t.integer "non_admin_area_id"
    t.integer "city_id"
    t.boolean "loaded_resource",   default: false, null: false
    t.integer "status_type",       default: 0
    t.integer "position",          default: 0
  end

  add_index "locations", ["admin_area_id"], name: "index_locations_on_admin_area_id", using: :btree
  add_index "locations", ["aoguid"], name: "index_locations_on_aoguid", using: :btree
  add_index "locations", ["city_id"], name: "index_locations_on_city_id", using: :btree
  add_index "locations", ["location_id"], name: "index_locations_on_location_id", using: :btree
  add_index "locations", ["location_type"], name: "index_locations_on_location_type", using: :btree
  add_index "locations", ["non_admin_area_id"], name: "index_locations_on_non_admin_area_id", using: :btree
  add_index "locations", ["parentguid"], name: "index_locations_on_parentguid", using: :btree
  add_index "locations", ["title"], name: "index_locations_on_title", using: :btree

  create_table "neighborhoods", force: true do |t|
    t.integer "location_id"
    t.integer "neighbor_id"
  end

  add_index "neighborhoods", ["location_id", "neighbor_id"], name: "by_location_neighbor", using: :btree
  add_index "neighborhoods", ["location_id"], name: "index_neighborhoods_on_location_id", using: :btree
  add_index "neighborhoods", ["neighbor_id"], name: "index_neighborhoods_on_neighbor_id", using: :btree

  create_table "notepads", force: true do |t|
    t.integer  "user_id"
    t.integer  "advertisement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notepads", ["advertisement_id"], name: "index_notepads_on_advertisement_id", using: :btree
  add_index "notepads", ["user_id"], name: "index_notepads_on_user_id", using: :btree

  create_table "phones", force: true do |t|
    t.string  "number"
    t.string  "original"
    t.integer "user_id"
  end

  add_index "phones", ["user_id"], name: "index_phones_on_user_id", using: :btree

  create_table "photos", force: true do |t|
    t.integer  "advertisement_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "advertisement_photo_file_name"
    t.string   "advertisement_photo_content_type"
    t.integer  "advertisement_photo_file_size"
    t.datetime "advertisement_photo_updated_at"
  end

  create_table "sections", force: true do |t|
    t.integer "advertisements_count", default: 0
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
    t.text    "p2"
    t.string  "short_title"
  end

  add_index "sections", ["location_id"], name: "index_sections_on_location_id", using: :btree
  add_index "sections", ["offer_type", "category", "location_id", "property_type"], name: "index_sections_on_ot_c_li_pt", using: :btree
  add_index "sections", ["url"], name: "index_sections_on_url", using: :btree

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
    t.integer  "role"
    t.integer  "source",                 default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
