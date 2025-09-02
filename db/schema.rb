# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_25_000305) do
  create_table "doctors", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.string "specialization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "nurses", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.string "specialization"
    t.integer "doctor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.index ["doctor_id"], name: "index_nurses_on_doctor_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.integer "age"
    t.integer "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "blood_type"
    t.date "admission_date"
    t.string "diagnosis"
    t.integer "condition"
    t.datetime "discharge_date"
    t.index ["room_id"], name: "index_patients_on_room_id"
  end

  create_table "room_doctors", force: :cascade do |t|
    t.integer "room_id", null: false
    t.integer "doctor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "finish_date"
    t.boolean "active"
    t.index ["doctor_id"], name: "index_room_doctors_on_doctor_id"
    t.index ["room_id", "doctor_id"], name: "index_room_doctors_on_room_id_and_doctor_id", unique: true
    t.index ["room_id"], name: "index_room_doctors_on_room_id"
  end

  create_table "room_nurses", force: :cascade do |t|
    t.integer "room_id", null: false
    t.integer "nurse_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "finish_date"
    t.boolean "active"
    t.index ["nurse_id"], name: "index_room_nurses_on_nurse_id"
    t.index ["room_id", "nurse_id"], name: "index_room_nurses_on_room_id_and_nurse_id", unique: true
    t.index ["room_id"], name: "index_room_nurses_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "room_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "room_type"
    t.integer "room_status"
    t.integer "capacity"
    t.index ["room_number"], name: "index_rooms_on_room_number", unique: true
    t.index ["room_status"], name: "index_rooms_on_room_status"
    t.index ["room_type", "room_status"], name: "index_rooms_on_room_type_and_room_status"
    t.index ["room_type"], name: "index_rooms_on_room_type"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "nurses", "doctors"
  add_foreign_key "patients", "rooms"
  add_foreign_key "room_doctors", "doctors"
  add_foreign_key "room_doctors", "rooms"
  add_foreign_key "room_nurses", "nurses"
  add_foreign_key "room_nurses", "rooms"
  add_foreign_key "sessions", "users"
end
