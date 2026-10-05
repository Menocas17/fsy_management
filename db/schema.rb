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

ActiveRecord::Schema[8.1].define(version: 2026_10_05_220000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "category", default: 0, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "location"
    t.integer "audience", default: 0, null: false
    t.string "target_roles", default: [], null: false, array: true
    t.text "logistics_notes"
    t.text "counselors_notes"
    t.text "youth_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_activities_on_starts_at"
  end

  create_table "activity_responsibles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activity_id", null: false
    t.uuid "participant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id", "participant_id"], name: "index_activity_responsibles_on_activity_id_and_participant_id", unique: true
    t.index ["activity_id"], name: "index_activity_responsibles_on_activity_id"
    t.index ["participant_id"], name: "index_activity_responsibles_on_participant_id"
  end

  create_table "alert_dismissals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "alert_id", null: false
    t.datetime "created_at", null: false
    t.index ["alert_id"], name: "index_alert_dismissals_on_alert_id"
    t.index ["user_id", "alert_id"], name: "index_alert_dismissals_on_user_id_and_alert_id", unique: true
  end

  create_table "alerts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sender_id"
    t.string "sender_name", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.integer "audience", default: 0, null: false
    t.string "target_roles", default: [], null: false, array: true
    t.integer "priority", default: 0, null: false
    t.boolean "send_email", default: false, null: false
    t.integer "source", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "activity_id"
    t.uuid "recipient_id"
    t.string "link_path"
    t.uuid "recipient_ids", default: [], null: false, array: true
    t.index ["activity_id"], name: "index_alerts_on_activity_id"
    t.index ["created_at"], name: "index_alerts_on_created_at"
    t.index ["recipient_id"], name: "index_alerts_on_recipient_id"
    t.index ["recipient_ids"], name: "index_alerts_on_recipient_ids", using: :gin
    t.index ["sender_id"], name: "index_alerts_on_sender_id"
    t.index ["target_roles"], name: "index_alerts_on_target_roles", using: :gin
  end

  create_table "app_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_app_settings_on_key", unique: true
  end

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_id", null: false
    t.uuid "activity_id"
    t.uuid "assigned_by_id"
    t.string "assigned_by_name", null: false
    t.string "title"
    t.text "details"
    t.datetime "starts_at"
    t.string "location"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_assignments_on_activity_id"
    t.index ["assigned_by_id"], name: "index_assignments_on_assigned_by_id"
    t.index ["participant_id"], name: "index_assignments_on_participant_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_name", null: false
    t.string "action", null: false
    t.integer "category", null: false
    t.string "summary", null: false
    t.string "target_type"
    t.uuid "target_id"
    t.string "target_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["category"], name: "index_audit_logs_on_category"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
  end

  create_table "auxiliar_companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "coordinator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "second_coordinator_id"
    t.index ["coordinator_id"], name: "index_auxiliar_companies_on_coordinator_id"
    t.index ["second_coordinator_id"], name: "index_auxiliar_companies_on_second_coordinator_id"
  end

  create_table "checkins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "participant_id", null: false
    t.uuid "recorded_by_id"
    t.string "recorded_by_name", null: false
    t.datetime "recorded_at", null: false
    t.integer "source", default: 0, null: false
    t.string "client_token"
    t.index ["client_token"], name: "index_checkins_on_client_token", unique: true
    t.index ["participant_id"], name: "index_checkins_on_participant_id", unique: true
    t.index ["recorded_at"], name: "index_checkins_on_recorded_at"
    t.index ["recorded_by_id"], name: "index_checkins_on_recorded_by_id"
  end

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "auxiliar_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
    t.string "nickname"
    t.integer "dining_hall"
    t.index ["auxiliar_company_id"], name: "index_companies_on_auxiliar_company_id"
    t.index ["number"], name: "index_companies_on_number", unique: true
  end

  create_table "expense_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.bigint "budget_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon", default: "wallet", null: false
    t.string "color", default: "primary", null: false
    t.index "lower((name)::text)", name: "index_expense_categories_on_lower_name", unique: true
  end

  create_table "expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expense_category_id"
    t.uuid "logistics_area_id"
    t.string "concept", null: false
    t.string "vendor"
    t.text "notes"
    t.string "currency", default: "NIO", null: false
    t.decimal "exchange_rate", precision: 10, scale: 4, default: "1.0", null: false
    t.bigint "estimated_cents", null: false
    t.date "planned_on"
    t.bigint "actual_cents"
    t.date "spent_on"
    t.integer "payment_method"
    t.integer "status", default: 0, null: false
    t.uuid "presented_by_id"
    t.string "presented_by_name", null: false
    t.uuid "approved_by_id"
    t.string "approved_by_name"
    t.datetime "approved_at"
    t.uuid "rejected_by_id"
    t.string "rejected_by_name"
    t.datetime "rejected_at"
    t.text "rejection_reason"
    t.text "justification"
    t.uuid "justified_by_id"
    t.string "justified_by_name"
    t.datetime "justified_at"
    t.text "justification_rejection"
    t.uuid "consolidated_by_id"
    t.string "consolidated_by_name"
    t.datetime "consolidated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_expenses_on_approved_by_id"
    t.index ["consolidated_by_id"], name: "index_expenses_on_consolidated_by_id"
    t.index ["expense_category_id"], name: "index_expenses_on_expense_category_id"
    t.index ["justified_by_id"], name: "index_expenses_on_justified_by_id"
    t.index ["logistics_area_id"], name: "index_expenses_on_logistics_area_id"
    t.index ["presented_by_id"], name: "index_expenses_on_presented_by_id"
    t.index ["rejected_by_id"], name: "index_expenses_on_rejected_by_id"
    t.index ["status"], name: "index_expenses_on_status"
  end

  create_table "infirmary_notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "infirmary_visit_id", null: false
    t.uuid "author_id"
    t.string "author_name", null: false
    t.text "body"
    t.boolean "medication", default: false, null: false
    t.jsonb "vitals", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_infirmary_notes_on_author_id"
    t.index ["infirmary_visit_id"], name: "index_infirmary_notes_on_infirmary_visit_id"
  end

  create_table "infirmary_visits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "reason", null: false
    t.text "reason_detail"
    t.datetime "announced_at"
    t.uuid "announced_by_id"
    t.string "announced_by_name"
    t.datetime "admitted_at"
    t.uuid "admitted_by_id"
    t.string "admitted_by_name"
    t.datetime "discharged_at"
    t.uuid "discharged_by_id"
    t.string "discharged_by_name"
    t.integer "disposition"
    t.text "discharge_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admitted_by_id"], name: "index_infirmary_visits_on_admitted_by_id"
    t.index ["announced_by_id"], name: "index_infirmary_visits_on_announced_by_id"
    t.index ["discharged_at"], name: "index_infirmary_visits_on_discharged_at"
    t.index ["discharged_by_id"], name: "index_infirmary_visits_on_discharged_by_id"
    t.index ["participant_id"], name: "index_infirmary_visits_on_participant_id"
    t.index ["participant_id"], name: "index_infirmary_visits_one_open_per_participant", unique: true, where: "(discharged_at IS NULL)"
  end

  create_table "inventories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "color", default: "primary", null: false
    t.string "icon", default: "package", null: false
    t.string "code_prefix", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "infirmary", default: false, null: false
    t.index ["code_prefix"], name: "index_inventories_on_code_prefix", unique: true
    t.index ["name"], name: "index_inventories_on_name", unique: true
  end

  create_table "inventory_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_id", null: false
    t.string "name", null: false
    t.string "code", null: false
    t.string "unit", default: "u", null: false
    t.integer "minimum", default: 0, null: false
    t.integer "quantity", default: 0, null: false
    t.string "location"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_inventory_items_on_code", unique: true
    t.index ["inventory_id", "name"], name: "index_inventory_items_on_inventory_id_and_name"
    t.index ["inventory_id"], name: "index_inventory_items_on_inventory_id"
  end

  create_table "inventory_movements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_item_id", null: false
    t.uuid "participant_id"
    t.string "participant_name", null: false
    t.integer "delta", null: false
    t.integer "reason", default: 0, null: false
    t.integer "source", default: 0, null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "infirmary_note_id"
    t.index ["infirmary_note_id"], name: "index_inventory_movements_on_infirmary_note_id"
    t.index ["inventory_item_id", "created_at"], name: "index_inventory_movements_on_inventory_item_id_and_created_at"
    t.index ["inventory_item_id"], name: "index_inventory_movements_on_inventory_item_id"
    t.index ["participant_id"], name: "index_inventory_movements_on_participant_id"
  end

  create_table "login_attempts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email_address", null: false
    t.uuid "user_id"
    t.integer "result", default: 0, null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_login_attempts_on_created_at"
    t.index ["user_id"], name: "index_login_attempts_on_user_id"
  end

  create_table "logistics_areas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "checkin", default: false, null: false
    t.boolean "finance", default: false, null: false
    t.boolean "food", default: false, null: false
    t.boolean "nursing", default: false, null: false
    t.index ["name"], name: "index_logistics_areas_on_name", unique: true
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "associable_type", null: false
    t.uuid "associable_id", null: false
    t.uuid "participant_id", null: false
    t.integer "role", null: false
    t.integer "gender", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["associable_type", "associable_id", "role", "gender"], name: "idx_memberships_gender_uniqueness", unique: true
    t.index ["associable_type", "associable_id"], name: "index_memberships_on_associable"
    t.index ["participant_id"], name: "index_memberships_on_participant_id"
  end

  create_table "night_attendance_marks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "night_attendance_id", null: false
    t.uuid "participant_id", null: false
    t.integer "status", null: false
    t.integer "absence_reason"
    t.string "absence_detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["night_attendance_id", "participant_id"], name: "idx_on_night_attendance_id_participant_id_5159a1e4de", unique: true
    t.index ["night_attendance_id"], name: "index_night_attendance_marks_on_night_attendance_id"
    t.index ["participant_id"], name: "index_night_attendance_marks_on_participant_id"
  end

  create_table "night_attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "company_id", null: false
    t.date "night_on", null: false
    t.integer "gender", null: false
    t.uuid "taken_by_id"
    t.string "taken_by_name", null: false
    t.datetime "confirmed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "night_on", "gender"], name: "index_night_attendances_on_company_id_and_night_on_and_gender", unique: true
    t.index ["company_id"], name: "index_night_attendances_on_company_id"
    t.index ["night_on"], name: "index_night_attendances_on_night_on"
    t.index ["taken_by_id"], name: "index_night_attendances_on_taken_by_id"
  end

  create_table "participant_import_rows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_import_id", null: false
    t.integer "row_number", null: false
    t.jsonb "values", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.jsonb "issues", default: [], null: false
    t.uuid "participant_id"
    t.string "resolved_by_name"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_participant_import_rows_on_participant_id"
    t.index ["participant_import_id", "status"], name: "idx_on_participant_import_id_status_d5a7a48eac"
    t.index ["participant_import_id"], name: "index_participant_import_rows_on_participant_import_id"
  end

  create_table "participant_imports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "filename", null: false
    t.uuid "uploaded_by_id"
    t.string "uploaded_by_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uploaded_by_id"], name: "index_participant_imports_on_uploaded_by_id"
  end

  create_table "participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "rol"
    t.string "first_name"
    t.string "last_name"
    t.integer "age"
    t.integer "stake"
    t.integer "ward"
    t.date "date_of_inscription"
    t.integer "shirt_number"
    t.string "room"
    t.jsonb "person_in_charge"
    t.jsonb "medical_info"
    t.text "additional_instructions"
    t.string "identity_document"
    t.integer "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "contact_info"
    t.uuid "company_id"
    t.uuid "logistics_area_id"
    t.string "code"
    t.string "preferred_name"
    t.date "birth_date"
    t.string "other_stake"
    t.string "other_ward"
    t.index ["code"], name: "index_participants_on_code", unique: true
    t.index ["company_id"], name: "index_participants_on_company_id"
    t.index ["logistics_area_id"], name: "index_participants_on_logistics_area_id"
  end

  create_table "push_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.string "auth_key", null: false
    t.string "device"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "training_attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "training_id", null: false
    t.uuid "participant_id", null: false
    t.uuid "recorded_by_id"
    t.string "recorded_by_name", null: false
    t.datetime "recorded_at", null: false
    t.integer "source", default: 0, null: false
    t.string "client_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_token"], name: "index_training_attendances_on_client_token", unique: true
    t.index ["participant_id"], name: "index_training_attendances_on_participant_id"
    t.index ["recorded_by_id"], name: "index_training_attendances_on_recorded_by_id"
    t.index ["training_id", "participant_id"], name: "index_training_attendances_on_training_id_and_participant_id", unique: true
    t.index ["training_id"], name: "index_training_attendances_on_training_id"
  end

  create_table "trainings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.date "held_on", null: false
    t.string "location"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["held_on"], name: "index_trainings_on_held_on", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "participant_id"
    t.datetime "alerts_read_at"
    t.boolean "superadmin", default: false, null: false
    t.datetime "first_signed_in_at"
    t.datetime "alerts_cleared_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["participant_id"], name: "index_users_on_participant_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_responsibles", "activities"
  add_foreign_key "activity_responsibles", "participants", on_delete: :cascade
  add_foreign_key "alert_dismissals", "alerts", on_delete: :cascade
  add_foreign_key "alert_dismissals", "users", on_delete: :cascade
  add_foreign_key "alerts", "activities", on_delete: :nullify
  add_foreign_key "alerts", "participants", column: "recipient_id", on_delete: :cascade
  add_foreign_key "alerts", "participants", column: "sender_id", on_delete: :nullify
  add_foreign_key "assignments", "activities", on_delete: :nullify
  add_foreign_key "assignments", "participants"
  add_foreign_key "assignments", "participants", column: "assigned_by_id", on_delete: :nullify
  add_foreign_key "audit_logs", "participants", column: "actor_id", on_delete: :nullify
  add_foreign_key "auxiliar_companies", "participants", column: "coordinator_id", on_delete: :nullify
  add_foreign_key "auxiliar_companies", "participants", column: "second_coordinator_id", on_delete: :nullify
  add_foreign_key "checkins", "participants"
  add_foreign_key "checkins", "participants", column: "recorded_by_id", on_delete: :nullify
  add_foreign_key "companies", "auxiliar_companies"
  add_foreign_key "expenses", "expense_categories"
  add_foreign_key "expenses", "logistics_areas"
  add_foreign_key "expenses", "participants", column: "approved_by_id", on_delete: :nullify
  add_foreign_key "expenses", "participants", column: "consolidated_by_id", on_delete: :nullify
  add_foreign_key "expenses", "participants", column: "justified_by_id", on_delete: :nullify
  add_foreign_key "expenses", "participants", column: "presented_by_id", on_delete: :nullify
  add_foreign_key "expenses", "participants", column: "rejected_by_id", on_delete: :nullify
  add_foreign_key "infirmary_notes", "infirmary_visits"
  add_foreign_key "infirmary_notes", "participants", column: "author_id", on_delete: :nullify
  add_foreign_key "infirmary_visits", "participants"
  add_foreign_key "infirmary_visits", "participants", column: "admitted_by_id", on_delete: :nullify
  add_foreign_key "infirmary_visits", "participants", column: "announced_by_id", on_delete: :nullify
  add_foreign_key "infirmary_visits", "participants", column: "discharged_by_id", on_delete: :nullify
  add_foreign_key "inventory_items", "inventories"
  add_foreign_key "inventory_movements", "infirmary_notes", on_delete: :nullify
  add_foreign_key "inventory_movements", "inventory_items"
  add_foreign_key "inventory_movements", "participants", on_delete: :nullify
  add_foreign_key "login_attempts", "users", on_delete: :nullify
  add_foreign_key "memberships", "participants"
  add_foreign_key "night_attendance_marks", "night_attendances", on_delete: :cascade
  add_foreign_key "night_attendance_marks", "participants", on_delete: :cascade
  add_foreign_key "night_attendances", "companies", on_delete: :cascade
  add_foreign_key "night_attendances", "participants", column: "taken_by_id", on_delete: :nullify
  add_foreign_key "participant_import_rows", "participant_imports", on_delete: :cascade
  add_foreign_key "participant_import_rows", "participants", on_delete: :nullify
  add_foreign_key "participant_imports", "participants", column: "uploaded_by_id", on_delete: :nullify
  add_foreign_key "participants", "companies"
  add_foreign_key "participants", "logistics_areas", on_delete: :nullify
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "training_attendances", "participants"
  add_foreign_key "training_attendances", "participants", column: "recorded_by_id", on_delete: :nullify
  add_foreign_key "training_attendances", "trainings"
  add_foreign_key "users", "participants"
end
