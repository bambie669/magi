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

ActiveRecord::Schema[7.1].define(version: 2025_12_31_104358) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.string "name"
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.string "name"
    t.date "due_date"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_milestones_on_project_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "notification_type", null: false
    t.text "message", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "test_case_templates", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "preconditions"
    t.text "steps"
    t.text "expected_result"
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_test_case_templates_on_project_id"
    t.index ["user_id"], name: "index_test_case_templates_on_user_id"
  end

  create_table "test_cases", force: :cascade do |t|
    t.string "title", null: false
    t.text "preconditions"
    t.text "steps"
    t.text "expected_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "test_scope_id", null: false
    t.string "cypress_id"
    t.index ["cypress_id"], name: "index_test_cases_on_cypress_id", unique: true
    t.index ["test_scope_id"], name: "index_test_cases_on_test_scope_id"
  end

  create_table "test_run_cases", force: :cascade do |t|
    t.bigint "test_run_id", null: false
    t.bigint "test_case_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "user_id"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_test_run_cases_on_status"
    t.index ["test_case_id"], name: "index_test_run_cases_on_test_case_id"
    t.index ["test_run_id", "test_case_id"], name: "index_test_run_cases_on_test_run_id_and_test_case_id", unique: true
    t.index ["test_run_id"], name: "index_test_run_cases_on_test_run_id"
    t.index ["user_id"], name: "index_test_run_cases_on_user_id"
  end

  create_table "test_runs", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_test_runs_on_project_id"
    t.index ["user_id"], name: "index_test_runs_on_user_id"
  end

  create_table "test_scopes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "test_suite_id", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_test_scopes_on_parent_id"
    t.index ["test_suite_id", "parent_id", "name"], name: "index_test_scopes_on_suite_parent_name", unique: true
    t.index ["test_suite_id"], name: "index_test_scopes_on_test_suite_id"
  end

  create_table "test_suites", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_test_suites_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "theme", default: "nerv", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "milestones", "projects"
  add_foreign_key "notifications", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "test_case_templates", "projects"
  add_foreign_key "test_case_templates", "users"
  add_foreign_key "test_cases", "test_scopes"
  add_foreign_key "test_run_cases", "test_cases"
  add_foreign_key "test_run_cases", "test_runs"
  add_foreign_key "test_run_cases", "users"
  add_foreign_key "test_runs", "projects"
  add_foreign_key "test_runs", "users"
  add_foreign_key "test_scopes", "test_scopes", column: "parent_id"
  add_foreign_key "test_scopes", "test_suites"
  add_foreign_key "test_suites", "projects"
end
