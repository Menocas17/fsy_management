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

ActiveRecord::Schema[8.1].define(version: 2026_09_15_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "actor_id"
    t.string "actor_name", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.string "summary", null: false
    t.uuid "target_id"
    t.string "target_name"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["category"], name: "index_audit_logs_on_category"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
  end

  create_table "auxiliar_companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "coordinator_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "second_coordinator_id"
    t.datetime "updated_at", null: false
    t.index ["coordinator_id"], name: "index_auxiliar_companies_on_coordinator_id"
    t.index ["second_coordinator_id"], name: "index_auxiliar_companies_on_second_coordinator_id"
  end

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "auxiliar_company_id"
    t.datetime "created_at", null: false
    t.integer "dining_hall"
    t.string "name", null: false
    t.string "nickname"
    t.integer "number"
    t.datetime "updated_at", null: false
    t.index ["auxiliar_company_id"], name: "index_companies_on_auxiliar_company_id"
    t.index ["number"], name: "index_companies_on_number", unique: true
  end

  create_table "logistics_areas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_logistics_areas_on_name", unique: true
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "associable_id", null: false
    t.string "associable_type", null: false
    t.datetime "created_at", null: false
    t.integer "gender", null: false
    t.uuid "participant_id", null: false
    t.integer "role", null: false
    t.datetime "updated_at", null: false
    t.index ["associable_type", "associable_id", "role", "gender"], name: "idx_memberships_gender_uniqueness", unique: true
    t.index ["associable_type", "associable_id"], name: "index_memberships_on_associable"
    t.index ["participant_id"], name: "index_memberships_on_participant_id"
  end

  create_table "participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "additional_instructions"
    t.integer "age"
    t.uuid "company_id"
    t.jsonb "contact_info"
    t.datetime "created_at", null: false
    t.date "date_of_inscription"
    t.string "first_name"
    t.integer "gender"
    t.integer "identity_document"
    t.string "last_name"
    t.uuid "logistics_area_id"
    t.jsonb "medical_info"
    t.jsonb "person_in_charge"
    t.integer "rol"
    t.string "room"
    t.integer "shirt_number"
    t.integer "stake"
    t.datetime "updated_at", null: false
    t.integer "ward"
    t.index ["company_id"], name: "index_participants_on_company_id"
    t.index ["logistics_area_id"], name: "index_participants_on_logistics_area_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.uuid "participant_id"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["participant_id"], name: "index_users_on_participant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "participants", column: "actor_id", on_delete: :nullify
  add_foreign_key "auxiliar_companies", "participants", column: "coordinator_id"
  add_foreign_key "auxiliar_companies", "participants", column: "second_coordinator_id"
  add_foreign_key "companies", "auxiliar_companies"
  add_foreign_key "memberships", "participants"
  add_foreign_key "participants", "companies"
  add_foreign_key "participants", "logistics_areas", on_delete: :nullify
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "participants"
end
