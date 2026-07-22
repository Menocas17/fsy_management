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

ActiveRecord::Schema[8.1].define(version: 2026_07_22_201814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "additional_instructions"
    t.integer "age"
    t.integer "company"
    t.datetime "created_at", null: false
    t.date "date_of_inscription"
    t.string "first_name"
    t.integer "genre"
    t.integer "identity_document"
    t.string "last_name"
    t.jsonb "medical_info"
    t.string "respond_to"
    t.integer "rol"
    t.string "room"
    t.integer "shirt_number"
    t.integer "stake"
    t.datetime "updated_at", null: false
    t.integer "ward"
  end
end
