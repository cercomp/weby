# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100507153616) do

  create_table "menus", :force => true do |t|
    t.string   "title"
    t.integer  "father_id"
    t.string   "position"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paginas", :force => true do |t|
    t.date     "dt_cadastro"
    t.date     "dt_publica"
    t.date     "dt_inicio"
    t.date     "dt_fim"
    t.string   "imagem"
    t.string   "posicao"
    t.string   "status"
    t.integer  "autor_id"
    t.string   "editor"
    t.string   "editor_chefe"
    t.string   "texto"
    t.string   "url"
    t.integer  "site_id"
    t.string   "fonte"
    t.string   "titulo"
    t.string   "texto_imagem"
    t.string   "resumo"
    t.string   "pdf"
    t.integer  "capa"
    t.datetime "time_capa"
    t.string   "kind"
    t.string   "local_realiza"
    t.datetime "inicio"
    t.datetime "fim"
    t.string   "email"
    t.string   "assunto"
    t.string   "texto_clob"
    t.string   "lado"
    t.string   "type",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", :force => true do |t|
    t.string   "name"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights_roles", :force => true do |t|
    t.integer  "right_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rights_roles", ["role_id", "right_id"], :name => "index_rights_roles_on_role_id_and_right_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "theme"
  end

  create_table "roles_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id"

  create_table "settings", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.text     "description"
    t.string   "group"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                     :null => false
    t.string   "email",                                     :null => false
    t.string   "crypted_password",                          :null => false
    t.string   "password_salt",                             :null => false
    t.string   "persistence_token",                         :null => false
    t.string   "single_access_token",                       :null => false
    t.string   "perishable_token",                          :null => false
    t.integer  "login_count",         :default => 0,        :null => false
    t.integer  "failed_login_count",  :default => 0,        :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "theme",               :default => "admin2"
    t.boolean  "status",              :default => false
    t.boolean  "is_admin",            :default => false
  end

end
