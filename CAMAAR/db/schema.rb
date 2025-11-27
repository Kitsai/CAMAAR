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

ActiveRecord::Schema[8.1].define(version: 2025_11_27_000753) do
  create_table "admins", primary_key: "user_id", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_admins_on_user_id", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.integer "form_id", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_answers_on_form_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "classCode"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "semester"
    t.integer "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_courses_on_teacher_id"
  end

  create_table "enrollments", id: false, force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["student_id", "course_id"], name: "index_enrollments_on_student_id_and_course_id", unique: true
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "form_requests", id: false, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "form_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["form_id"], name: "index_form_requests_on_form_id"
    t.index ["user_id", "form_id"], name: "index_form_requests_on_user_id_and_form_id", unique: true
    t.index ["user_id"], name: "index_form_requests_on_user_id"
  end

  create_table "forms", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "question_set_id", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_forms_on_admin_id"
    t.index ["course_id"], name: "index_forms_on_course_id"
    t.index ["question_set_id"], name: "index_forms_on_question_set_id"
  end

  create_table "question_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "data"
    t.datetime "updated_at", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.datetime "created_at", null: false
    t.integer "question_set_id", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_templates_on_admin_id"
    t.index ["question_set_id"], name: "index_templates_on_question_set_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admins", "users"
  add_foreign_key "answers", "forms"
  add_foreign_key "courses", "users", column: "teacher_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users", column: "student_id"
  add_foreign_key "form_requests", "forms"
  add_foreign_key "form_requests", "users"
  add_foreign_key "forms", "admins", primary_key: "user_id"
  add_foreign_key "forms", "courses"
  add_foreign_key "forms", "question_sets"
  add_foreign_key "templates", "admins", primary_key: "user_id"
  add_foreign_key "templates", "question_sets"
end
