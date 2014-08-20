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

ActiveRecord::Schema.define(version: 20140820174548) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_records", force: true do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.string   "browser"
    t.string   "ip_address"
    t.string   "controller"
    t.string   "action"
    t.text     "params"
    t.string   "note"
    t.integer  "loggeable_id"
    t.string   "loggeable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "activity_records", ["site_id"], name: "index_activity_records_on_site_id", using: :btree
  add_index "activity_records", ["user_id"], name: "index_activity_records_on_user_id", using: :btree

  create_table "extension_sites", force: true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "extension_sites", ["site_id"], name: "index_extension_sites_on_site_id", using: :btree

  create_table "feedback_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
    t.text     "emails"
  end

  add_index "feedback_groups", ["site_id"], name: "index_groups_on_site_id", using: :btree

  create_table "feedback_messages", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "message"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback_messages", ["site_id"], name: "index_feedbacks_on_site_id", using: :btree

  create_table "feedback_messages_groups", id: false, force: true do |t|
    t.integer "message_id", null: false
    t.integer "group_id",   null: false
  end

  add_index "feedback_messages_groups", ["group_id"], name: "index_feedbacks_groups_on_group_id", using: :btree
  add_index "feedback_messages_groups", ["message_id", "group_id"], name: "index_feedbacks_groups_on_feedback_id_and_group_id", unique: true, using: :btree
  add_index "feedback_messages_groups", ["message_id"], name: "index_feedbacks_groups_on_feedback_id", using: :btree

  create_table "groupings", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "hidden",     default: false
  end

  create_table "groupings_sites", force: true do |t|
    t.integer "grouping_id"
    t.integer "site_id"
  end

  add_index "groupings_sites", ["grouping_id"], name: "index_groupings_sites_on_grouping_id", using: :btree
  add_index "groupings_sites", ["site_id"], name: "index_groupings_sites_on_site_id", using: :btree

  create_table "groups_users", id: false, force: true do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "groups_users", ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree
  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id"], name: "index_groups_users_on_user_id", using: :btree

  create_table "locales", force: true do |t|
    t.string   "name"
    t.string   "flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locales_sites", id: false, force: true do |t|
    t.integer "locale_id", null: false
    t.integer "site_id",   null: false
  end

  add_index "locales_sites", ["locale_id", "site_id"], name: "index_locales_sites_on_locale_id_and_site_id", unique: true, using: :btree
  add_index "locales_sites", ["locale_id"], name: "index_locales_sites_on_locale_id", using: :btree
  add_index "locales_sites", ["site_id"], name: "index_locales_sites_on_site_id", using: :btree

  create_table "menu_item_i18ns", force: true do |t|
    t.integer  "menu_item_id", null: false
    t.integer  "locale_id",    null: false
    t.string   "title",        null: false
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "menu_item_i18ns", ["locale_id"], name: "index_menu_item_i18ns_on_locale_id", using: :btree
  add_index "menu_item_i18ns", ["menu_item_id", "locale_id"], name: "menu_item_i18ns_menu_item_id_key", unique: true, using: :btree
  add_index "menu_item_i18ns", ["menu_item_id"], name: "index_menu_item_i18ns_on_menu_item_id", using: :btree

  create_table "menu_items", force: true do |t|
    t.integer  "menu_id",                     null: false
    t.boolean  "separator",   default: false
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "url"
    t.integer  "parent_id"
    t.integer  "position",    default: 0,     null: false
    t.boolean  "new_tab",     default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "html_class"
    t.boolean  "publish",     default: true
  end

  add_index "menu_items", ["menu_id"], name: "index_menu_items_on_menu_id", using: :btree
  add_index "menu_items", ["parent_id"], name: "index_menu_items_on_parent_id", using: :btree
  add_index "menu_items", ["target_id"], name: "index_menu_items_on_target_id", using: :btree

  create_table "menus", force: true do |t|
    t.integer  "site_id",    null: false
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "menus", ["site_id"], name: "index_menus_on_site_id", using: :btree

  create_table "notifications", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "old_menus", force: true do |t|
    t.string   "title"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
    t.text     "description"
  end

  add_index "old_menus", ["page_id"], name: "index_old_menus_on_page_id", using: :btree

  create_table "page_i18ns", force: true do |t|
    t.integer  "page_id"
    t.integer  "locale_id"
    t.string   "title"
    t.text     "summary"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_i18ns", ["locale_id"], name: "index_page_i18ns_on_locale_id", using: :btree
  add_index "page_i18ns", ["page_id"], name: "index_page_i18ns_on_page_id", using: :btree

  create_table "pages", force: true do |t|
    t.datetime "date_begin_at"
    t.datetime "date_end_at"
    t.string   "status"
    t.integer  "author_id"
    t.string   "url"
    t.integer  "site_id"
    t.string   "source"
    t.string   "kind"
    t.string   "local"
    t.datetime "event_begin"
    t.datetime "event_end"
    t.string   "event_email"
    t.string   "subject"
    t.string   "align"
    t.string   "type",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repository_id"
    t.string   "size"
    t.boolean  "publish",       default: false
    t.boolean  "front",         default: false
    t.integer  "position"
    t.integer  "view_count",    default: 0
    t.datetime "deleted_at"
  end

  add_index "pages", ["author_id"], name: "index_pages_on_author_id", using: :btree
  add_index "pages", ["repository_id"], name: "index_pages_on_repository_id", using: :btree
  add_index "pages", ["site_id"], name: "index_pages_on_site_id", using: :btree

  create_table "pages_repositories", id: false, force: true do |t|
    t.integer "page_id"
    t.integer "repository_id"
  end

  add_index "pages_repositories", ["page_id"], name: "index_pages_repositories_on_page_id", using: :btree
  add_index "pages_repositories", ["repository_id"], name: "index_pages_repositories_on_repository_id", using: :btree

  create_table "repositories", force: true do |t|
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "archive_file_name"
    t.string   "archive_content_type"
    t.integer  "archive_file_size"
    t.datetime "archive_updated_at"
    t.string   "description"
    t.datetime "deleted_at"
    t.string   "archive_fingerprint"
    t.string   "title"
    t.string   "legend"
  end

  add_index "repositories", ["site_id"], name: "index_repositories_on_site_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
    t.text     "permissions"
  end

  add_index "roles", ["site_id"], name: "index_roles_on_site_id", using: :btree

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true, using: :btree
  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "name"
    t.string   "value"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_components", force: true do |t|
    t.integer  "site_id"
    t.string   "place_holder"
    t.text     "settings"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "publish",      default: true
    t.integer  "visibility",   default: 0
    t.string   "alias"
  end

  add_index "site_components", ["site_id"], name: "index_site_components_on_site_id", using: :btree

  create_table "site_components_bkp", force: true do |t|
    t.integer  "site_id"
    t.string   "place_holder"
    t.text     "settings"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "publish"
  end

  create_table "sites", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.text     "description"
    t.integer  "top_banner_id"
    t.integer  "top_banner_width"
    t.integer  "top_banner_height"
    t.integer  "body_width"
    t.text     "footer"
    t.string   "theme"
    t.boolean  "view_desc_pages",              default: false
    t.string   "per_page",                     default: "5, 15, 30, 50, 100"
    t.integer  "per_page_default",             default: 25
    t.boolean  "menu_dropdown",                default: false
    t.string   "title",             limit: 50
    t.integer  "parent_id"
    t.integer  "view_count",                   default: 0
    t.string   "domain"
  end

  add_index "sites", ["parent_id"], name: "index_sites_on_parent_id", using: :btree
  add_index "sites", ["top_banner_id"], name: "index_sites_on_top_banner_id", using: :btree

  create_table "sites_menus", force: true do |t|
    t.integer  "site_id"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",  default: 0
    t.string   "category"
    t.integer  "position"
  end

  add_index "sites_menus", ["menu_id"], name: "index_sites_menus_on_menu_id", using: :btree
  add_index "sites_menus", ["site_id"], name: "index_sites_menus_on_site_id", using: :btree

  create_table "sites_pages", force: true do |t|
    t.integer  "site_id"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "sites_pages", ["page_id"], name: "index_sites_pages_on_page_id", using: :btree
  add_index "sites_pages", ["site_id"], name: "index_sites_pages_on_site_id", using: :btree

  create_table "sticker_banners", force: true do |t|
    t.datetime "date_begin_at"
    t.datetime "date_end_at"
    t.string   "title"
    t.text     "text"
    t.string   "url"
    t.integer  "width"
    t.integer  "height"
    t.boolean  "hide",          default: false
    t.integer  "repository_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "size"
    t.boolean  "publish",       default: false
    t.integer  "site_id"
    t.integer  "position"
    t.integer  "page_id"
    t.boolean  "new_tab",       default: false
    t.integer  "click_count",   default: 0
  end

  add_index "sticker_banners", ["page_id"], name: "index_banners_on_page_id", using: :btree
  add_index "sticker_banners", ["repository_id"], name: "index_banners_on_repository_id", using: :btree
  add_index "sticker_banners", ["site_id"], name: "index_banners_on_site_id", using: :btree
  add_index "sticker_banners", ["user_id"], name: "index_banners_on_user_id", using: :btree

  create_table "styles", force: true do |t|
    t.string   "name"
    t.text     "css"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "publish",    default: true
    t.integer  "site_id",                   null: false
    t.integer  "position",   default: 0
    t.integer  "style_id"
  end

  add_index "styles", ["site_id"], name: "index_styles_on_owner_id", using: :btree
  add_index "styles", ["style_id"], name: "index_styles_on_style_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_login_histories", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "login_ip"
    t.string   "browser"
    t.string   "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_login_histories", ["user_id"], name: "index_user_login_histories_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "login",                                  null: false
    t.string   "email",                                  null: false
    t.string   "encrypted_password",                     null: false
    t.string   "password_salt",                          null: false
    t.integer  "sign_in_count",          default: 0,     null: false
    t.integer  "failed_attempts",        default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_admin",               default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "locale_id"
    t.string   "unread_notifications"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["locale_id"], name: "index_users_on_locale_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "views", force: true do |t|
    t.integer  "site_id"
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.integer  "user_id"
    t.string   "request_path"
    t.text     "user_agent"
    t.string   "session_hash"
    t.string   "ip_address"
    t.text     "referer"
    t.text     "query_string"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "views", ["site_id"], name: "index_views_on_site_id", using: :btree
  add_index "views", ["viewable_id"], name: "index_views_on_viewable_id", using: :btree

  create_table "weby_settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weby_settings", ["thing_type", "thing_id", "var"], name: "index_weby_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  add_foreign_key "activity_records", "sites", name: "activity_records_site_id_fk"
  add_foreign_key "activity_records", "users", name: "activity_records_user_id_fk"

  add_foreign_key "extension_sites", "sites", name: "extension_sites_site_id_fk"

  add_foreign_key "feedback_groups", "sites", name: "groups_site_id_fk"

  add_foreign_key "feedback_messages", "sites", name: "feedbacks_site_id_fk"

  add_foreign_key "feedback_messages_groups", "feedback_groups", name: "feedbacks_groups_group_id_fk", column: "group_id"
  add_foreign_key "feedback_messages_groups", "feedback_messages", name: "feedbacks_groups_feedback_id_fk", column: "message_id"

  add_foreign_key "groupings_sites", "groupings", name: "groupings_sites_grouping_id_fk"
  add_foreign_key "groupings_sites", "sites", name: "groupings_sites_site_id_fk"

  add_foreign_key "groups_users", "feedback_groups", name: "groups_users_group_id_fk", column: "group_id"
  add_foreign_key "groups_users", "users", name: "groups_users_user_id_fk"

  add_foreign_key "locales_sites", "locales", name: "locales_sites_locale_id_fk"
  add_foreign_key "locales_sites", "sites", name: "locales_sites_site_id_fk"

  add_foreign_key "menu_item_i18ns", "locales", name: "locale_menu_item_i18ns", dependent: :restrict
  add_foreign_key "menu_item_i18ns", "locales", name: "menu_item_i18ns_locale_id_fk"
  add_foreign_key "menu_item_i18ns", "menu_items", name: "menu_item_i18ns_menu_item_id_fk"
  add_foreign_key "menu_item_i18ns", "menu_items", name: "menu_item_menu_item_i18ns", dependent: :delete

  add_foreign_key "menu_items", "menu_items", name: "menu_items_parent_id_fk", column: "parent_id"
  add_foreign_key "menu_items", "menus", name: "menu_items_menu_id_fk"
  add_foreign_key "menu_items", "menus", name: "menu_menu_items", dependent: :delete

  add_foreign_key "menus", "sites", name: "menus_site_id_fk"
  add_foreign_key "menus", "sites", name: "site_menus", dependent: :delete

  add_foreign_key "notifications", "users", name: "notifications_user_id_fk"

  add_foreign_key "old_menus", "pages", name: "old_menus_page_id_fk"

  add_foreign_key "page_i18ns", "locales", name: "page_i18ns_locale_id_fk"
  add_foreign_key "page_i18ns", "pages", name: "page_i18ns_page_id_fk"

  add_foreign_key "pages", "repositories", name: "pages_repository_id_fk"
  add_foreign_key "pages", "sites", name: "pages_site_id_fk"
  add_foreign_key "pages", "users", name: "pages_author_id_fk", column: "author_id"

  add_foreign_key "pages_repositories", "pages", name: "pages_repositories_page_id_fk"
  add_foreign_key "pages_repositories", "repositories", name: "pages_repositories_repository_id_fk"

  add_foreign_key "repositories", "sites", name: "repositories_site_id_fk"

  add_foreign_key "roles", "sites", name: "roles_site_id_fk"

  add_foreign_key "roles_users", "roles", name: "roles_users_role_id_fk"
  add_foreign_key "roles_users", "users", name: "roles_users_user_id_fk"

  add_foreign_key "site_components", "sites", name: "site_components_site_id_fk"

  add_foreign_key "sites", "repositories", name: "sites_top_banner_id_fk", column: "top_banner_id"
  add_foreign_key "sites", "sites", name: "sites_parent_id_fk", column: "parent_id"

  add_foreign_key "sites_menus", "menus", name: "sites_menus_menu_id_fk"
  add_foreign_key "sites_menus", "sites", name: "sites_menus_site_id_fk"

  add_foreign_key "sticker_banners", "pages", name: "banners_page_id_fk"
  add_foreign_key "sticker_banners", "repositories", name: "banners_repository_id_fk"
  add_foreign_key "sticker_banners", "sites", name: "banners_site_id_fk"
  add_foreign_key "sticker_banners", "users", name: "banners_user_id_fk"

  add_foreign_key "styles", "sites", name: "fk_owner", dependent: :delete
  add_foreign_key "styles", "sites", name: "styles_owner_id_fk"
  add_foreign_key "styles", "styles", name: "styles_style_id_fk"

  add_foreign_key "user_login_histories", "users", name: "user_login_histories_user_id_fk"

  add_foreign_key "users", "locales", name: "users_locale_id_fk"

  add_foreign_key "views", "sites", name: "views_site_id_fk"
  add_foreign_key "views", "users", name: "views_user_id_fk"

end
