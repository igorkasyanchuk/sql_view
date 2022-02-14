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

ActiveRecord::Schema.define(version: 2022_02_14_211243) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "parents", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.integer "age"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "workers", force: :cascade do |t|
    t.string "title"
    t.integer "jobable_id"
    t.string "jobable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end


  create_sql_view "active_account_views", sql: <<-SQL
    CREATE  VIEW "active_account_views" AS
       SELECT accounts.id,
      accounts.name,
      accounts.active,
      accounts.created_at,
      accounts.updated_at
     FROM accounts
    WHERE (accounts.active = true);
  SQL

  create_sql_view "deleted_account_views", sql: <<-SQL
    CREATE  MATERIALIZED  VIEW "deleted_account_views" AS
       SELECT accounts.id,
      accounts.name,
      accounts.active,
      accounts.created_at,
      accounts.updated_at
     FROM accounts
    WHERE (1 = 0);
  SQL

  create_sql_view "bulgaria_views", sql: <<-SQL
    CREATE  MATERIALIZED  VIEW "bulgaria_views" AS
       SELECT users.id,
      users.name,
      users.country,
      users.age,
      users.created_at,
      users.updated_at
     FROM users;
  SQL

  create_sql_view "monther_anna_views", sql: <<-SQL
    CREATE  VIEW "monther_anna_views" AS
       SELECT parents.id,
      parents.name,
      parents.type,
      parents.created_at,
      parents.updated_at
     FROM parents
    WHERE ((parents.type)::text = 'Mother'::text);
  SQL

  create_sql_view "active_worker_views", sql: <<-SQL
    CREATE  VIEW "active_worker_views" AS
       SELECT workers.id,
      workers.title,
      workers.jobable_id,
      workers.jobable_type,
      workers.created_at,
      workers.updated_at
     FROM workers;
  SQL

end
