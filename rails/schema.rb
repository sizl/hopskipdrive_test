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

ActiveRecord::Schema.define(version: 20190612123025) do

  create_table "rides", force: :cascade do |t|
    t.integer  "users_id",          limit: 4,                  null: false
    t.integer  "drivers_id",        limit: 4,                  null: false
    t.time     "pickup_time",                                  null: false
    t.string   "start_address",     limit: 255,                null: false
    t.string   "end_address",       limit: 255,                null: false
    t.string   "start_location",    limit: 255
    t.string   "end_location",      limit: 255
    t.decimal  "distance",                      precision: 10
    t.datetime "start_at"
    t.datetime "ended_at"
    t.datetime "cancelled_at"
    t.integer  "scheduled_ride_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduled_rides", force: :cascade do |t|
    t.integer  "users_id",      limit: 4,   null: false
    t.string   "name",          limit: 255, null: false
    t.time     "pickup_time",               null: false
    t.string   "start_address", limit: 255, null: false
    t.string   "end_address",   limit: 255, null: false
    t.string   "repeat_type",   limit: 255, null: false
    t.string   "repeat_value",  limit: 255, null: false
    t.datetime "ends_at",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
