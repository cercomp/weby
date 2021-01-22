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

ActiveRecord::Schema.define(version: 2020_12_23_182948) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_records", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "site_id"
    t.string "browser"
    t.string "ip_address"
    t.string "controller"
    t.string "action"
    t.text "params"
    t.string "note"
    t.integer "loggeable_id"
    t.string "loggeable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_activity_records_on_site_id"
    t.index ["user_id"], name: "index_activity_records_on_user_id"
  end

  create_table "auth_sources", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "source_type"
    t.string "source_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calendar_event_i18ns", id: :serial, force: :cascade do |t|
    t.integer "calendar_event_id"
    t.integer "locale_id"
    t.string "name"
    t.string "place"
    t.text "information"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["calendar_event_id"], name: "index_calendar_event_i18ns_on_calendar_event_id"
    t.index ["locale_id"], name: "index_calendar_event_i18ns_on_locale_id"
  end

  create_table "calendar_events", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "repository_id"
    t.integer "user_id"
    t.datetime "begin_at"
    t.datetime "end_at"
    t.string "email"
    t.string "url"
    t.string "kind"
    t.datetime "deleted_at"
    t.integer "view_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["repository_id"], name: "index_calendar_events_on_repository_id"
    t.index ["site_id"], name: "index_calendar_events_on_site_id"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "components", id: :serial, force: :cascade do |t|
    t.string "place_holder"
    t.text "settings"
    t.string "name"
    t.integer "position"
    t.boolean "publish", default: true
    t.integer "visibility", default: 0
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "skin_id"
    t.index ["skin_id"], name: "index_components_on_skin_id"
  end

  create_table "extensions", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "settings", default: {}
    t.index ["site_id"], name: "index_extensions_on_site_id"
  end

  create_table "feedback_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.text "emails"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["site_id"], name: "index_groups_on_site_id"
  end

  create_table "feedback_messages", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "subject"
    t.text "message"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read_status", default: false
    t.index ["site_id"], name: "index_feedbacks_on_site_id"
  end

  create_table "feedback_messages_groups", id: false, force: :cascade do |t|
    t.integer "message_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_feedbacks_groups_on_group_id"
    t.index ["message_id"], name: "index_feedbacks_groups_on_feedback_id"
  end

  create_table "groupings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
  end

  create_table "groupings_sites", id: :serial, force: :cascade do |t|
    t.integer "grouping_id"
    t.integer "site_id"
    t.index ["grouping_id"], name: "index_groupings_sites_on_grouping_id"
    t.index ["site_id"], name: "index_groupings_sites_on_site_id"
  end

  create_table "journal_news", id: :serial, force: :cascade do |t|
    t.datetime "date_begin_at"
    t.datetime "date_end_at"
    t.string "status"
    t.integer "user_id"
    t.string "url"
    t.integer "site_id"
    t.string "source"
    t.string "local"
    t.integer "repository_id"
    t.boolean "front", default: false
    t.integer "position"
    t.integer "view_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["repository_id"], name: "index_journal_news_on_repository_id"
    t.index ["site_id"], name: "index_journal_news_on_site_id"
    t.index ["user_id"], name: "index_journal_news_on_user_id"
  end

  create_table "journal_news_i18ns", id: :serial, force: :cascade do |t|
    t.integer "journal_news_id"
    t.integer "locale_id"
    t.string "title"
    t.text "summary"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journal_news_id"], name: "index_journal_news_i18ns_on_journal_news_id"
    t.index ["locale_id"], name: "index_journal_news_i18ns_on_locale_id"
  end

  create_table "journal_news_sites", id: :serial, force: :cascade do |t|
    t.integer "journal_news_id", null: false
    t.integer "site_id", null: false
    t.integer "position"
    t.boolean "front", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["journal_news_id", "site_id"], name: "index_journal_news_sites_on_journal_news_id_and_site_id"
  end

  create_table "journal_newsletter_histories", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "news_id"
    t.integer "user_id"
    t.text "emails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_newsletters", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "group"
    t.string "email"
    t.string "token"
    t.boolean "confirm"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locales", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locales_sites", id: false, force: :cascade do |t|
    t.integer "locale_id"
    t.integer "site_id"
    t.index ["locale_id"], name: "index_locales_sites_on_locale_id"
    t.index ["site_id"], name: "index_locales_sites_on_site_id"
  end

  create_table "menu_item_i18ns", id: :serial, force: :cascade do |t|
    t.integer "menu_item_id"
    t.integer "locale_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale_id"], name: "index_menu_item_i18ns_on_locale_id"
    t.index ["menu_item_id"], name: "index_menu_item_i18ns_on_menu_item_id"
  end

  create_table "menu_items", id: :serial, force: :cascade do |t|
    t.integer "menu_id"
    t.boolean "separator", default: false
    t.integer "target_id"
    t.string "target_type"
    t.string "url"
    t.integer "parent_id"
    t.integer "position", default: 0
    t.boolean "new_tab", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "html_class"
    t.boolean "publish", default: true
    t.index ["menu_id"], name: "index_menu_items_on_menu_id"
    t.index ["parent_id"], name: "index_menu_items_on_parent_id"
    t.index ["target_id"], name: "index_menu_items_on_target_id"
  end

  create_table "menus", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0
    t.index ["site_id"], name: "index_menus_on_site_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "page_i18ns", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.integer "locale_id"
    t.string "title"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["locale_id"], name: "index_page_i18ns_on_locale_id"
    t.index ["page_id"], name: "index_page_i18ns_on_page_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "user_id"
    t.boolean "publish", default: false
    t.datetime "deleted_at"
    t.integer "view_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id"], name: "index_pages_on_site_id"
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "posts_repositories", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "repository_id"
    t.string "post_type"
    t.index ["post_id"], name: "index_posts_repositories_on_post_id"
    t.index ["repository_id"], name: "index_posts_repositories_on_repository_id"
  end

  create_table "repositories", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "archive_file_name"
    t.string "archive_content_type"
    t.integer "archive_file_size"
    t.datetime "archive_updated_at"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "archive_fingerprint"
    t.string "title"
    t.string "legend"
    t.bigint "user_id"
    t.index ["site_id"], name: "index_repositories_on_site_id"
    t.index ["user_id"], name: "index_repositories_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "permissions"
    t.index ["site_id"], name: "index_roles_on_site_id"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "value"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group"
  end

  create_table "simple_captcha_data", id: :serial, force: :cascade do |t|
    t.string "key", limit: 40
    t.string "value", limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "idx_key"
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.integer "body_width"
    t.text "footer"
    t.string "theme"
    t.boolean "show_pages_author", default: false
    t.string "per_page", default: "5, 15, 30, 50, 100"
    t.integer "per_page_default", default: 25
    t.boolean "menu_dropdown", default: false
    t.string "title", limit: 50
    t.integer "parent_id"
    t.integer "view_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "top_banner_id"
    t.integer "top_banner_width"
    t.integer "top_banner_height"
    t.string "domain"
    t.text "head_html"
    t.string "status", default: "active"
    t.boolean "restrict_theme", default: false
    t.jsonb "settings", default: {}
    t.string "google_analytics"
    t.boolean "show_pages_created_at", default: false
    t.boolean "show_pages_updated_at", default: false
    t.index ["parent_id"], name: "index_sites_on_parent_id"
    t.index ["status"], name: "index_sites_on_status"
    t.index ["top_banner_id"], name: "index_sites_on_top_banner_id"
  end

  create_table "skins", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "theme"
    t.string "name"
    t.text "variables"
    t.boolean "active", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id"], name: "index_skins_on_site_id"
  end

  create_table "sticker_banner_sites", id: :serial, force: :cascade do |t|
    t.integer "sticker_banner_id", null: false
    t.integer "site_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sticker_banner_id", "site_id"], name: "index_sticker_banner_sites_on_sticker_banner_id_and_site_id"
  end

  create_table "sticker_banners", id: :serial, force: :cascade do |t|
    t.datetime "date_begin_at"
    t.datetime "date_end_at"
    t.string "title"
    t.text "text"
    t.string "url"
    t.integer "width"
    t.integer "height"
    t.boolean "hide", default: false
    t.integer "repository_id"
    t.integer "user_id"
    t.string "size"
    t.boolean "publish", default: false
    t.integer "site_id"
    t.integer "position"
    t.integer "target_id"
    t.boolean "new_tab", default: false
    t.integer "click_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_type"
    t.boolean "shareable", default: false
    t.index ["repository_id"], name: "index_banners_on_repository_id"
    t.index ["site_id"], name: "index_banners_on_site_id"
    t.index ["target_id"], name: "index_banners_on_page_id"
    t.index ["user_id"], name: "index_banners_on_user_id"
  end

  create_table "styles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "css"
    t.boolean "publish", default: true
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "style_id"
    t.integer "skin_id"
    t.index ["skin_id"], name: "index_styles_on_skin_id"
    t.index ["style_id"], name: "index_styles_on_style_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_login_histories", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "login_ip"
    t.string "browser"
    t.string "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_login_histories_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "encrypted_password"
    t.string "password_salt"
    t.integer "sign_in_count", default: 0
    t.integer "failed_attempts", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "is_admin", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "mobile"
    t.integer "locale_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unread_notifications"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "locked_at"
    t.jsonb "preferences", default: {}
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locale_id"], name: "index_users_on_locale_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "views", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "viewable_id"
    t.string "viewable_type"
    t.integer "user_id"
    t.string "request_path"
    t.text "user_agent"
    t.string "session_hash"
    t.string "ip_address"
    t.string "referer"
    t.string "query_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at", "site_id"], name: "index_views_on_created_at_and_site_id"
    t.index ["created_at"], name: "index_views_on_created_at"
    t.index ["ip_address"], name: "index_views_on_ip_address"
    t.index ["session_hash"], name: "index_views_on_session_hash"
    t.index ["site_id"], name: "index_views_on_site_id"
    t.index ["user_id"], name: "index_views_on_user_id"
  end

  add_foreign_key "activity_records", "sites", name: "activity_records_site_id_fk"
  add_foreign_key "activity_records", "users", name: "activity_records_user_id_fk"
  add_foreign_key "calendar_event_i18ns", "calendar_events", name: "calendar_event_i18ns_calendar_event_id_fk"
  add_foreign_key "calendar_event_i18ns", "locales", name: "calendar_event_i18ns_locale_id_fk"
  add_foreign_key "calendar_events", "repositories", name: "calendar_events_repository_id_fk"
  add_foreign_key "calendar_events", "sites", name: "calendar_events_site_id_fk"
  add_foreign_key "calendar_events", "users", name: "calendar_events_user_id_fk"
  add_foreign_key "extensions", "sites", name: "extension_sites_site_id_fk"
  add_foreign_key "feedback_groups", "sites", name: "groups_site_id_fk"
  add_foreign_key "feedback_messages", "sites", name: "feedbacks_site_id_fk"
  add_foreign_key "feedback_messages_groups", "feedback_groups", column: "group_id", name: "feedbacks_groups_group_id_fk"
  add_foreign_key "feedback_messages_groups", "feedback_messages", column: "message_id", name: "feedbacks_groups_feedback_id_fk"
  add_foreign_key "groupings_sites", "groupings", name: "groupings_sites_grouping_id_fk"
  add_foreign_key "groupings_sites", "sites", name: "groupings_sites_site_id_fk"
  add_foreign_key "journal_news", "repositories", name: "pages_repository_id_fk"
  add_foreign_key "journal_news", "sites", name: "pages_site_id_fk"
  add_foreign_key "journal_news", "users", name: "pages_author_id_fk"
  add_foreign_key "journal_news_i18ns", "journal_news", name: "page_i18ns_page_id_fk"
  add_foreign_key "journal_news_i18ns", "locales", name: "page_i18ns_locale_id_fk"
  add_foreign_key "locales_sites", "locales", name: "locales_sites_locale_id_fk"
  add_foreign_key "locales_sites", "sites", name: "locales_sites_site_id_fk"
  add_foreign_key "menu_item_i18ns", "locales", name: "menu_item_i18ns_locale_id_fk"
  add_foreign_key "menu_item_i18ns", "menu_items", name: "menu_item_i18ns_menu_item_id_fk"
  add_foreign_key "menu_items", "menu_items", column: "parent_id", name: "menu_items_parent_id_fk"
  add_foreign_key "menu_items", "menus", name: "menu_items_menu_id_fk"
  add_foreign_key "menus", "sites", name: "menus_site_id_fk"
  add_foreign_key "notifications", "users", name: "notifications_user_id_fk"
  add_foreign_key "posts_repositories", "repositories", name: "pages_repositories_repository_id_fk"
  add_foreign_key "repositories", "sites", name: "repositories_site_id_fk"
  add_foreign_key "repositories", "users"
  add_foreign_key "roles", "sites", name: "roles_site_id_fk"
  add_foreign_key "roles_users", "roles", name: "roles_users_role_id_fk"
  add_foreign_key "roles_users", "users", name: "roles_users_user_id_fk"
  add_foreign_key "sites", "repositories", column: "top_banner_id", name: "sites_top_banner_id_fk"
  add_foreign_key "sites", "sites", column: "parent_id", name: "sites_parent_id_fk"
  add_foreign_key "sticker_banners", "repositories", name: "banners_repository_id_fk"
  add_foreign_key "sticker_banners", "sites", name: "banners_site_id_fk"
  add_foreign_key "sticker_banners", "users", name: "banners_user_id_fk"
  add_foreign_key "styles", "styles", name: "styles_style_id_fk"
  add_foreign_key "user_login_histories", "users", name: "user_login_histories_user_id_fk"
  add_foreign_key "users", "locales", name: "users_locale_id_fk"
  add_foreign_key "views", "sites", name: "views_site_id_fk"
  add_foreign_key "views", "users", name: "views_user_id_fk"
end
