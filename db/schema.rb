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

ActiveRecord::Schema[8.0].define(version: 2025_06_03_114019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chat_messages", id: :serial, force: :cascade do |t|
    t.integer "operation_room_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.bigint "_id", null: false
    t.index ["operation_room_id"], name: "index_chat_messages_on_operation_room_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "command_responses", id: :serial, force: :cascade do |t|
    t.integer "command_id", null: false
    t.text "content", null: false
    t.string "response_type", limit: 20, default: "text"
    t.integer "priority", default: 0
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at", precision: nil
  end

  create_table "commands", id: :serial, force: :cascade do |t|
    t.text "keyword", null: false
    t.text "description"
    t.integer "customer_id"
    t.integer "operation_room_id"
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at", precision: nil

    t.unique_constraint ["keyword", "customer_id"], name: "commands_keyword_customer_id_unique"
    t.unique_constraint ["keyword", "operation_room_id"], name: "commands_keyword_operation_room_id_unique"
  end

  create_table "customer_admin_rooms", id: :serial, force: :cascade do |t|
    t.bigint "admin_room_id", null: false
    t.integer "customer_id", null: false
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: nil, default: -> { "now()" }

    t.unique_constraint ["admin_room_id"], name: "customer_admin_rooms_admin_room_id_unique"
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "name"
    t.text "email"
    t.text "phone_number"
    t.text "password"
    t.datetime "last_login_at", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.text "token"
    t.boolean "is_admin", default: false, null: false
    t.index ["token"], name: "index_customers_on_token", unique: true
    t.unique_constraint ["user_id"], name: "customers_user_id_unique"
  end

  create_table "features", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.string "category", default: "general", null: false
    t.index ["category"], name: "index_features_on_category"
  end

  create_table "operation_rooms", id: :serial, force: :cascade do |t|
    t.bigint "chat_room_id", null: false
    t.text "open_chat_link"
    t.text "origin_title"
    t.text "title"
    t.bigint "accumulated_payment_amount", default: 0
    t.string "platform_type", limit: 20, null: false
    t.string "room_type", limit: 20, null: false
    t.integer "customer_admin_room_id"
    t.integer "customer_admin_user_id"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.datetime "due_date", precision: nil

    t.unique_constraint ["chat_room_id"], name: "operation_rooms_chat_room_id_unique"
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.integer "price", null: false
    t.json "features"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
  end

  create_table "room_features", id: :serial, force: :cascade do |t|
    t.integer "operation_room_id"
    t.integer "feature_id"
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
  end

  create_table "room_plan_histories", id: :serial, force: :cascade do |t|
    t.integer "operation_room_id"
    t.integer "plan_id"
    t.datetime "start_date", precision: nil, null: false
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "now()" }
  end

  create_table "room_user_events", id: :serial, force: :cascade do |t|
    t.integer "operation_room_id", null: false
    t.integer "user_id", null: false
    t.string "event_type", limit: 10, null: false
    t.datetime "event_at", precision: nil, default: -> { "now()" }
  end

  create_table "room_user_nickname_histories", id: :serial, force: :cascade do |t|
    t.integer "chat_room_id", null: false
    t.integer "user_id", null: false
    t.text "previous_nickname"
    t.text "new_nickname"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at", precision: nil
  end

  create_table "room_users", id: :serial, force: :cascade do |t|
    t.integer "operation_room_id", null: false
    t.integer "user_id", null: false
    t.text "nickname"
    t.string "role", limit: 20, null: false
    t.datetime "joined_at", precision: nil, default: -> { "now()" }
    t.datetime "left_at", precision: nil
  end

  create_table "attendances", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.bigint "kakao_user_id"
    t.integer "operation_room_id"
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index ["operation_room_id"], name: "index_attendances_on_operation_room_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
    t.index ["kakao_user_id"], name: "index_attendances_on_kakao_user_id"
  end

  add_foreign_key "chat_messages", "operation_rooms", name: "chat_messages_operation_room_id_operation_rooms_id_fk"
  add_foreign_key "command_responses", "commands", name: "command_responses_command_id_commands_id_fk"
  add_foreign_key "commands", "customers", name: "commands_customer_id_customers_id_fk"
  add_foreign_key "commands", "operation_rooms", name: "commands_operation_room_id_operation_rooms_id_fk"
  add_foreign_key "customer_admin_rooms", "customers", name: "customer_admin_rooms_customer_id_customers_id_fk"
  add_foreign_key "operation_rooms", "customer_admin_rooms", name: "operation_rooms_customer_admin_room_id_customer_admin_rooms_id_"
  add_foreign_key "operation_rooms", "customers", column: "customer_admin_user_id", name: "operation_rooms_customer_admin_user_id_customers_id_fk"
  add_foreign_key "room_features", "features", name: "room_features_feature_id_features_id_fk"
  add_foreign_key "room_features", "operation_rooms", name: "room_features_operation_room_id_operation_rooms_id_fk"
  add_foreign_key "room_plan_histories", "operation_rooms", name: "room_plan_histories_operation_room_id_operation_rooms_id_fk"
  add_foreign_key "room_plan_histories", "plans", name: "room_plan_histories_plan_id_plans_id_fk"
  add_foreign_key "room_user_events", "operation_rooms", name: "room_user_events_operation_room_id_operation_rooms_id_fk"
  add_foreign_key "room_users", "operation_rooms", name: "room_users_operation_room_id_operation_rooms_id_fk"
end
