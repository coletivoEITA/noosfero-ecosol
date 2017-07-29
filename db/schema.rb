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

ActiveRecord::Schema.define(version: 20170701160657) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abuse_reports", force: :cascade do |t|
    t.integer  "reporter_id"
    t.integer  "abuse_complaint_id"
    t.text     "content"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "action_tracker", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_type",      limit: 255
    t.integer  "target_id"
    t.string   "target_type",    limit: 255
    t.text     "params"
    t.string   "verb",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",             default: 0
    t.boolean  "visible",                    default: true
  end

  add_index "action_tracker", ["target_id", "target_type"], name: "index_action_tracker_on_dispatcher_id_and_dispatcher_type", using: :btree
  add_index "action_tracker", ["user_id", "user_type"], name: "index_action_tracker_on_user_id_and_user_type", using: :btree
  add_index "action_tracker", ["verb"], name: "index_action_tracker_on_verb", using: :btree

  create_table "action_tracker_notifications", force: :cascade do |t|
    t.integer "action_tracker_id"
    t.integer "profile_id"
  end

  add_index "action_tracker_notifications", ["action_tracker_id"], name: "index_action_tracker_notifications_on_action_tracker_id", using: :btree
  add_index "action_tracker_notifications", ["profile_id", "action_tracker_id"], name: "index_action_tracker_notifications_on_profile_id_and_action_tra", unique: true, using: :btree
  add_index "action_tracker_notifications", ["profile_id"], name: "index_action_tracker_notifications_on_profile_id", using: :btree

  create_table "article_followers", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "article_id"
    t.datetime "since"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "article_followers", ["article_id"], name: "index_article_followers_on_article_id", using: :btree
  add_index "article_followers", ["person_id", "article_id"], name: "index_article_followers_on_person_id_and_article_id", unique: true, using: :btree
  add_index "article_followers", ["person_id"], name: "index_article_followers_on_person_id", using: :btree

  create_table "article_privacy_exceptions", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "person_id"
  end

  create_table "article_versions", force: :cascade do |t|
    t.integer  "article_id"
    t.integer  "version"
    t.string   "name",                 limit: 255
    t.string   "slug",                 limit: 255
    t.text     "path",                             default: ""
    t.integer  "parent_id"
    t.text     "body"
    t.text     "abstract"
    t.integer  "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "last_changed_by_id"
    t.integer  "size"
    t.string   "content_type",         limit: 255
    t.string   "filename",             limit: 255
    t.integer  "height"
    t.integer  "width"
    t.string   "versioned_type",       limit: 255
    t.integer  "comments_count"
    t.boolean  "advertise",                        default: true
    t.boolean  "published",                        default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "children_count",                   default: 0
    t.boolean  "accept_comments",                  default: true
    t.integer  "reference_article_id"
    t.text     "setting"
    t.boolean  "notify_comments",                  default: false
    t.integer  "hits",                             default: 0
    t.datetime "published_at"
    t.string   "source",               limit: 255
    t.boolean  "highlighted",                      default: false
    t.string   "external_link",        limit: 255
    t.boolean  "thumbnails_processed",             default: false
    t.boolean  "is_image",                         default: false
    t.integer  "translation_of_id"
    t.string   "language",             limit: 255
    t.string   "source_name",          limit: 255
    t.integer  "license_id"
    t.integer  "image_id"
    t.integer  "position"
    t.integer  "spam_comments_count",              default: 0
    t.integer  "author_id"
    t.integer  "created_by_id"
  end

  add_index "article_versions", ["article_id"], name: "index_article_versions_on_article_id", using: :btree
  add_index "article_versions", ["parent_id"], name: "index_article_versions_on_parent_id", using: :btree
  add_index "article_versions", ["path", "profile_id"], name: "index_article_versions_on_path_and_profile_id", using: :btree
  add_index "article_versions", ["path"], name: "index_article_versions_on_path", using: :btree
  add_index "article_versions", ["published_at", "id"], name: "index_article_versions_on_published_at_and_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "slug",                 limit: 255
    t.text     "path",                             default: ""
    t.integer  "parent_id"
    t.text     "body"
    t.text     "abstract"
    t.integer  "profile_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "last_changed_by_id"
    t.integer  "version"
    t.string   "type",                 limit: 255
    t.integer  "size"
    t.string   "content_type",         limit: 255
    t.string   "filename",             limit: 255
    t.integer  "height"
    t.integer  "width"
    t.integer  "comments_count",                   default: 0
    t.boolean  "advertise",                        default: true
    t.boolean  "published",                        default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "children_count",                   default: 0
    t.boolean  "accept_comments",                  default: true
    t.integer  "reference_article_id"
    t.text     "setting"
    t.boolean  "notify_comments",                  default: true
    t.integer  "hits",                             default: 0
    t.datetime "published_at"
    t.string   "source",               limit: 255
    t.boolean  "highlighted",                      default: false
    t.string   "external_link",        limit: 255
    t.boolean  "thumbnails_processed",             default: false
    t.boolean  "is_image",                         default: false
    t.integer  "translation_of_id"
    t.string   "language",             limit: 255
    t.string   "source_name",          limit: 255
    t.integer  "license_id"
    t.integer  "image_id"
    t.integer  "position"
    t.integer  "spam_comments_count",              default: 0
    t.integer  "author_id"
    t.integer  "created_by_id"
    t.boolean  "show_to_followers",                default: true
    t.boolean  "archived",                         default: false
    t.integer  "followers_count",                  default: 0
    t.string   "editor",                           default: "tiny_mce", null: false
  end

  add_index "articles", ["comments_count"], name: "index_articles_on_comments_count", using: :btree
  add_index "articles", ["created_at"], name: "index_articles_on_created_at", using: :btree
  add_index "articles", ["hits"], name: "index_articles_on_hits", using: :btree
  add_index "articles", ["parent_id"], name: "index_articles_on_parent_id", using: :btree
  add_index "articles", ["path", "profile_id"], name: "index_articles_on_path_and_profile_id", using: :btree
  add_index "articles", ["path"], name: "index_articles_on_path", using: :btree
  add_index "articles", ["profile_id"], name: "index_articles_on_profile_id", using: :btree
  add_index "articles", ["published_at", "id"], name: "index_articles_on_published_at_and_id", using: :btree
  add_index "articles", ["slug"], name: "index_articles_on_slug", using: :btree
  add_index "articles", ["translation_of_id"], name: "index_articles_on_translation_of_id", using: :btree
  add_index "articles", ["type", "parent_id"], name: "index_articles_on_type_and_parent_id", using: :btree
  add_index "articles", ["type", "profile_id"], name: "index_articles_on_type_and_profile_id", using: :btree
  add_index "articles", ["type"], name: "index_articles_on_type", using: :btree

  create_table "articles_categories", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "category_id"
    t.boolean "virtual",     default: false
  end

  add_index "articles_categories", ["article_id"], name: "index_articles_categories_on_article_id", using: :btree
  add_index "articles_categories", ["category_id"], name: "index_articles_categories_on_category_id", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.integer  "box_id"
    t.string   "type",            limit: 255
    t.text     "settings"
    t.integer  "position"
    t.boolean  "enabled",                     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "fetched_at"
    t.boolean  "mirror",                      default: false
    t.integer  "mirror_block_id"
    t.integer  "observers_id"
    t.string   "subtitle",                    default: ""
  end

  add_index "blocks", ["box_id"], name: "index_blocks_on_box_id", using: :btree
  add_index "blocks", ["enabled"], name: "index_blocks_on_enabled", using: :btree
  add_index "blocks", ["fetched_at"], name: "index_blocks_on_fetched_at", using: :btree
  add_index "blocks", ["type"], name: "index_blocks_on_type", using: :btree

  create_table "boxes", force: :cascade do |t|
    t.string  "owner_type", limit: 255
    t.integer "owner_id"
    t.integer "position"
  end

  add_index "boxes", ["owner_type", "owner_id"], name: "index_boxes_on_owner_type_and_owner_id", using: :btree

  create_table "br_nivel2", id: false, force: :cascade do |t|
    t.string "cidade", limit: 255
    t.float  "lat"
    t.float  "lng"
  end

  create_table "bsc_plugin_contracts", force: :cascade do |t|
    t.string   "client_name",         limit: 255
    t.integer  "client_type"
    t.integer  "business_type"
    t.string   "state",               limit: 255
    t.string   "city",                limit: 255
    t.integer  "status",                          default: 0
    t.integer  "number_of_producers",             default: 0
    t.datetime "supply_start"
    t.datetime "supply_end"
    t.text     "annotations"
    t.integer  "bsc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bsc_plugin_contracts_enterprises", id: false, force: :cascade do |t|
    t.integer "contract_id"
    t.integer "enterprise_id"
  end

  create_table "bsc_plugin_sales", force: :cascade do |t|
    t.integer  "product_id",  null: false
    t.integer  "contract_id", null: false
    t.integer  "quantity",    null: false
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string  "name",                 limit: 255
    t.string  "slug",                 limit: 255
    t.text    "path",                             default: ""
    t.integer "environment_id"
    t.integer "parent_id"
    t.string  "type",                 limit: 255
    t.float   "lat"
    t.float   "lng"
    t.boolean "display_in_menu",                  default: false
    t.integer "children_count",                   default: 0
    t.boolean "accept_products",                  default: true
    t.integer "image_id"
    t.string  "acronym",              limit: 255
    t.string  "abbreviation",         limit: 255
    t.text    "ancestry"
    t.boolean "visible_for_articles",             default: true
    t.boolean "visible_for_profiles",             default: true
    t.boolean "choosable",                        default: true
    t.string  "display_color",        limit: 6
    t.string  "uuid"
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "categories_profiles", id: false, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "category_id"
    t.boolean "virtual",     default: false
  end

  add_index "categories_profiles", ["category_id"], name: "index_categories_profiles_on_category_id", using: :btree
  add_index "categories_profiles", ["profile_id"], name: "index_categories_profiles_on_profile_id", using: :btree

  create_table "certifiers", force: :cascade do |t|
    t.string   "name",           limit: 255, null: false
    t.text     "description"
    t.string   "link",           limit: 255
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "chat_messages", ["created_at"], name: "index_chat_messages_on_created_at", using: :btree
  add_index "chat_messages", ["from_id"], name: "index_chat_messages_on_from_id", using: :btree
  add_index "chat_messages", ["to_id"], name: "index_chat_messages_on_to_id", using: :btree

  create_table "circles", force: :cascade do |t|
    t.string   "name"
    t.integer  "person_id"
    t.string   "profile_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "circles", ["person_id", "name"], name: "circles_composite_key_index", unique: true, using: :btree

  create_table "comment_classification_plugin_comment_label_user", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "comment_id"
    t.integer  "label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_classification_plugin_comment_status_user", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "comment_id"
    t.integer  "status_id"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_classification_plugin_labels", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "color",      limit: 255
    t.boolean  "enabled",                default: true
    t.integer  "owner_id"
    t.string   "owner_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_classification_plugin_statuses", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.boolean  "enabled",                   default: true
    t.boolean  "enable_reason",             default: true
    t.integer  "owner_id"
    t.string   "owner_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "body"
    t.integer  "source_id"
    t.integer  "author_id"
    t.string   "name",        limit: 255
    t.string   "email",       limit: 255
    t.datetime "created_at"
    t.integer  "reply_of_id"
    t.string   "ip_address",  limit: 255
    t.boolean  "spam"
    t.string   "source_type", limit: 255
    t.string   "user_agent",  limit: 255
    t.string   "referrer",    limit: 255
    t.integer  "group_id"
    t.text     "settings"
  end

  add_index "comments", ["source_id", "spam"], name: "index_comments_on_source_id_and_spam", using: :btree

  create_table "contact_lists", force: :cascade do |t|
    t.text     "list"
    t.string   "error_fetching", limit: 255
    t.boolean  "fetched",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.string   "customized_type", default: "",    null: false
    t.integer  "customized_id",   default: 0,     null: false
    t.boolean  "public",          default: false, null: false
    t.integer  "custom_field_id", default: 0,     null: false
    t.text     "value",           default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_field_values", ["customized_type", "customized_id", "custom_field_id"], name: "index_custom_field_values", unique: true, using: :btree

  create_table "custom_fields", force: :cascade do |t|
    t.string   "name"
    t.string   "format",          default: ""
    t.text     "default_value",   default: ""
    t.string   "customized_type"
    t.text     "extras",          default: ""
    t.boolean  "active",          default: false
    t.boolean  "required",        default: false
    t.boolean  "signup",          default: false
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "moderation_task", default: false
  end

  add_index "custom_fields", ["customized_type", "name", "environment_id"], name: "index_custom_field", unique: true, using: :btree

  create_table "custom_forms_plugin_alternatives", force: :cascade do |t|
    t.string  "label",               limit: 255
    t.integer "field_id"
    t.boolean "selected_by_default",             default: false, null: false
    t.integer "position",                        default: 0
  end

  create_table "custom_forms_plugin_answers", force: :cascade do |t|
    t.text    "value"
    t.integer "field_id"
    t.integer "submission_id"
  end

  create_table "custom_forms_plugin_fields", force: :cascade do |t|
    t.string  "name",          limit: 255
    t.string  "slug",          limit: 255
    t.string  "type",          limit: 255
    t.string  "default_value", limit: 255
    t.float   "minimum"
    t.float   "maximum"
    t.integer "form_id"
    t.boolean "mandatory",                 default: false
    t.integer "position",                  default: 0
    t.string  "show_as",       limit: 255
  end

  create_table "custom_forms_plugin_forms", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "slug",               limit: 255
    t.text     "description"
    t.integer  "profile_id"
    t.datetime "begining"
    t.datetime "ending"
    t.boolean  "report_submissions",             default: false
    t.boolean  "on_membership",                  default: false
    t.string   "access",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "for_admission",                  default: false
  end

  create_table "custom_forms_plugin_submissions", force: :cascade do |t|
    t.string   "author_name",  limit: 255
    t.string   "author_email", limit: 255
    t.integer  "profile_id"
    t.integer  "form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delivery_plugin_methods", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "name",                           limit: 255
    t.text     "description"
    t.string   "recipient",                      limit: 255
    t.string   "address_line1",                  limit: 255
    t.string   "address_line2",                  limit: 255
    t.string   "postal_code",                    limit: 255
    t.string   "state",                          limit: 255
    t.string   "country",                        limit: 255
    t.string   "delivery_type",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "fixed_cost"
    t.decimal  "free_over_price"
    t.decimal  "distribution_margin_fixed"
    t.decimal  "distribution_margin_percentage"
  end

  add_index "delivery_plugin_methods", ["profile_id"], name: "index_distribution_plugin_delivery_methods_on_node_id", using: :btree

  create_table "delivery_plugin_options", force: :cascade do |t|
    t.integer  "owner_id"
    t.integer  "delivery_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_type",         limit: 255
  end

  add_index "delivery_plugin_options", ["delivery_method_id"], name: "distribution_plugin_delivery_options_dmid", using: :btree
  add_index "delivery_plugin_options", ["owner_id", "delivery_method_id"], name: "distribution_plugin_delivery_options_sid_dmid", using: :btree
  add_index "delivery_plugin_options", ["owner_id"], name: "index_distribution_plugin_delivery_options_on_session_id", using: :btree

  create_table "domains", force: :cascade do |t|
    t.string  "name",            limit: 255
    t.string  "owner_type",      limit: 255
    t.integer "owner_id"
    t.boolean "is_default",                  default: false
    t.string  "google_maps_key", limit: 255
    t.boolean "ssl"
  end

  add_index "domains", ["is_default"], name: "index_domains_on_is_default", using: :btree
  add_index "domains", ["name"], name: "index_domains_on_name", using: :btree
  add_index "domains", ["owner_id", "owner_type", "is_default"], name: "index_domains_on_owner_id_and_owner_type_and_is_default", using: :btree
  add_index "domains", ["owner_id", "owner_type"], name: "index_domains_on_owner_id_and_owner_type", using: :btree

  create_table "email_templates", force: :cascade do |t|
    t.string   "name"
    t.string   "template_type"
    t.string   "subject"
    t.text     "body"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "environments", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.string   "contact_email",                limit: 255
    t.boolean  "is_default"
    t.text     "settings"
    t.text     "design_data"
    t.text     "custom_header"
    t.text     "custom_footer"
    t.string   "theme",                        limit: 255, default: "default",              null: false
    t.text     "terms_of_use_acceptance_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "send_email_plugin_allow_to"
    t.integer  "reports_lower_bound",                      default: 0,                      null: false
    t.string   "languages",                    limit: 255
    t.string   "default_language",             limit: 255
    t.string   "redirection_after_login",      limit: 255, default: "keep_on_same_page"
    t.text     "signup_welcome_text"
    t.string   "noreply_email",                limit: 255
    t.string   "redirection_after_signup",     limit: 255, default: "keep_on_same_page"
    t.string   "date_format",                              default: "month_name_with_year"
    t.boolean  "enable_feed_proxy",                        default: false
    t.string   "http_feed_proxy"
    t.string   "https_feed_proxy"
    t.boolean  "disable_feed_ssl",                         default: false
  end

  create_table "external_feeds", force: :cascade do |t|
    t.string   "feed_title",    limit: 255
    t.datetime "fetched_at"
    t.text     "address"
    t.integer  "blog_id",                                  null: false
    t.boolean  "enabled",                   default: true, null: false
    t.boolean  "only_once",                 default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "error_message"
    t.integer  "update_errors",             default: 0
  end

  add_index "external_feeds", ["blog_id"], name: "index_external_feeds_on_blog_id", using: :btree
  add_index "external_feeds", ["enabled"], name: "index_external_feeds_on_enabled", using: :btree
  add_index "external_feeds", ["fetched_at"], name: "index_external_feeds_on_fetched_at", using: :btree

  create_table "favorite_enterprise_people", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "enterprise_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorite_enterprise_people", ["enterprise_id"], name: "index_favorite_enterprise_people_on_enterprise_id", using: :btree
  add_index "favorite_enterprise_people", ["person_id", "enterprise_id"], name: "index_favorite_enterprise_people_on_person_id_and_enterprise_id", using: :btree
  add_index "favorite_enterprise_people", ["person_id"], name: "index_favorite_enterprise_people_on_person_id", using: :btree

  create_table "fb_app_plugin_page_tab_configs", force: :cascade do |t|
    t.string   "page_id",    limit: 255
    t.text     "config",                 default: "--- {}\n\n"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
  end

  add_index "fb_app_plugin_page_tab_configs", ["page_id"], name: "index_fb_app_ecosol_store_plugin_page_configs_on_page_id", using: :btree
  add_index "fb_app_plugin_page_tab_configs", ["profile_id"], name: "index_fb_app_plugin_page_tab_configs_on_profile_id", using: :btree

  create_table "financial_plugin_transactions", force: :cascade do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "target_profile_id"
    t.integer  "origin_id"
    t.integer  "order_id"
    t.integer  "payment_id"
    t.integer  "payment_method_id"
    t.integer  "operator_id"
    t.text     "description"
    t.string   "direction"
    t.decimal  "balance"
    t.decimal  "value"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "financial_plugin_transactions", ["operator_id"], name: "index_financial_plugin_transactions_on_operator_id", using: :btree
  add_index "financial_plugin_transactions", ["order_id"], name: "index_financial_plugin_transactions_on_order_id", using: :btree
  add_index "financial_plugin_transactions", ["origin_id"], name: "index_financial_plugin_transactions_on_origin_id", using: :btree
  add_index "financial_plugin_transactions", ["payment_id"], name: "index_financial_plugin_transactions_on_payment_id", using: :btree
  add_index "financial_plugin_transactions", ["payment_method_id"], name: "index_financial_plugin_transactions_on_payment_method_id", using: :btree
  add_index "financial_plugin_transactions", ["target_profile_id"], name: "index_financial_plugin_transactions_on_target_profile_id", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.string   "group",      limit: 255
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["person_id", "friend_id"], name: "index_friendships_on_person_id_and_friend_id", using: :btree
  add_index "friendships", ["person_id"], name: "index_friendships_on_person_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer "parent_id"
    t.string  "content_type",         limit: 255
    t.string  "filename",             limit: 255
    t.string  "thumbnail",            limit: 255
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.boolean "thumbnails_processed",             default: false
    t.string  "label",                            default: ""
    t.integer "owner_id"
    t.string  "owner_type"
  end

  add_index "images", ["owner_type", "owner_id"], name: "index_images_on_owner_type_and_owner_id", using: :btree
  add_index "images", ["parent_id"], name: "index_images_on_parent_id", using: :btree

  create_table "inputs", force: :cascade do |t|
    t.integer  "product_id",                                 null: false
    t.integer  "product_category_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.decimal  "price_per_unit"
    t.decimal  "amount_used"
    t.boolean  "relevant_to_price",          default: true
    t.boolean  "is_from_solidarity_economy", default: false
    t.integer  "unit_id"
  end

  add_index "inputs", ["product_category_id"], name: "index_inputs_on_product_category_id", using: :btree
  add_index "inputs", ["product_id"], name: "index_inputs_on_product_id", using: :btree

  create_table "kinds", force: :cascade do |t|
    t.string  "name"
    t.string  "type"
    t.boolean "moderated",      default: false
    t.integer "environment_id"
  end

  create_table "kinds_profiles", force: :cascade do |t|
    t.integer "kind_id"
    t.integer "profile_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.string  "name",           limit: 255, null: false
    t.string  "slug",           limit: 255, null: false
    t.string  "url",            limit: 255
    t.integer "environment_id",             null: false
  end

  create_table "mail_schedules", force: :cascade do |t|
    t.integer  "dest_count"
    t.datetime "scheduled_to"
  end

  create_table "mailing_sents", force: :cascade do |t|
    t.integer  "mailing_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailings", force: :cascade do |t|
    t.string   "type",        limit: 255
    t.string   "subject",     limit: 255
    t.text     "body"
    t.integer  "source_id"
    t.string   "source_type", limit: 255
    t.integer  "person_id"
    t.string   "locale",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data"
  end

  create_table "mark_comment_as_read_plugin", force: :cascade do |t|
    t.integer "comment_id"
    t.integer "person_id"
  end

  add_index "mark_comment_as_read_plugin", ["comment_id", "person_id"], name: "index_mark_comment_as_read_plugin_on_comment_id_and_person_id", unique: true, using: :btree

  create_table "mezuro_plugin_metrics", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.float    "value"
    t.integer  "metricable_id"
    t.string   "metricable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mezuro_plugin_projects", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "identifier",       limit: 255
    t.string   "personal_webpage", limit: 255
    t.text     "description"
    t.string   "repository_url",   limit: 255
    t.string   "svn_error",        limit: 255
    t.boolean  "with_tab"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "national_region_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "national_regions", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.string   "national_region_code",        limit: 255
    t.string   "parent_national_region_code", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "national_region_type_id"
  end

  add_index "national_regions", ["name"], name: "name_index", using: :btree
  add_index "national_regions", ["national_region_code"], name: "code_index", using: :btree

  create_table "oauth2_authorizations", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth2_resource_owner_type", limit: 255
    t.integer  "oauth2_resource_owner_id"
    t.integer  "client_id"
    t.string   "scope",                      limit: 255
    t.string   "code",                       limit: 40
    t.string   "access_token_hash",          limit: 40
    t.string   "refresh_token_hash",         limit: 40
    t.datetime "expires_at"
  end

  add_index "oauth2_authorizations", ["access_token_hash"], name: "index_oauth2_authorizations_on_access_token_hash", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "code"], name: "index_oauth2_authorizations_on_client_id_and_code", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "oauth2_resource_owner_type", "oauth2_resource_owner_id"], name: "index_owner_client_pairs", unique: true, using: :btree
  add_index "oauth2_authorizations", ["client_id", "refresh_token_hash"], name: "index_oauth2_authorizations_on_client_id_and_refresh_token_hash", unique: true, using: :btree

  create_table "oauth2_clients", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth2_client_owner_type", limit: 255
    t.integer  "oauth2_client_owner_id"
    t.string   "name",                     limit: 255
    t.string   "client_id",                limit: 255
    t.string   "client_secret",            limit: 255
    t.string   "redirect_uri",             limit: 255
    t.integer  "image_id"
    t.string   "site",                     limit: 255
  end

  add_index "oauth2_clients", ["client_id"], name: "index_oauth2_clients_on_client_id", unique: true, using: :btree
  add_index "oauth2_clients", ["name"], name: "index_oauth2_clients_on_name", unique: true, using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id",             null: false
    t.integer  "application_id",                null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",                    null: false
    t.text     "redirect_uri",                  null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255, null: false
    t.string   "uid",          limit: 255, null: false
    t.string   "secret",       limit: 255, null: false
    t.text     "redirect_uri",             null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "oauth_client_plugin_auths", force: :cascade do |t|
    t.integer  "provider_id"
    t.boolean  "enabled"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "type",             limit: 255
    t.string   "provider_user_id", limit: 255
    t.text     "access_token"
    t.datetime "expires_at"
    t.text     "scope"
    t.text     "data",                         default: "--- {}\n"
    t.integer  "profile_id"
  end

  add_index "oauth_client_plugin_auths", ["profile_id"], name: "index_oauth_client_plugin_auths_on_profile_id", using: :btree
  add_index "oauth_client_plugin_auths", ["provider_id"], name: "index_oauth_client_plugin_auths_on_provider_id", using: :btree
  add_index "oauth_client_plugin_auths", ["provider_user_id"], name: "index_oauth_client_plugin_auths_on_provider_user_id", using: :btree
  add_index "oauth_client_plugin_auths", ["type"], name: "index_oauth_client_plugin_auths_on_type", using: :btree

  create_table "oauth_client_plugin_providers", force: :cascade do |t|
    t.integer  "environment_id"
    t.string   "strategy",       limit: 255
    t.string   "name",           limit: 255
    t.text     "options"
    t.boolean  "enabled"
    t.integer  "image_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "client_id"
    t.text     "client_secret"
  end

  add_index "oauth_client_plugin_providers", ["client_id"], name: "index_oauth_client_plugin_providers_on_client_id", using: :btree

  create_table "oauth_plugin_provider_auths", force: :cascade do |t|
    t.string   "type",             limit: 255
    t.integer  "profile_id"
    t.integer  "provider_id"
    t.string   "provider_user_id", limit: 255
    t.text     "access_token"
    t.datetime "expires_at"
    t.text     "scope"
    t.text     "data",                         default: "--- {}\n"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "oauth_plugin_provider_auths", ["profile_id", "provider_id"], name: "index_oauth_plugin_provider_auths_on_profile_id_and_provider_id", using: :btree
  add_index "oauth_plugin_provider_auths", ["profile_id", "provider_user_id"], name: "oauth_index_profile_id_and_provider_user_id", using: :btree
  add_index "oauth_plugin_provider_auths", ["profile_id"], name: "index_oauth_plugin_provider_auths_on_profile_id", using: :btree
  add_index "oauth_plugin_provider_auths", ["provider_id"], name: "index_oauth_plugin_provider_auths_on_provider_id", using: :btree
  add_index "oauth_plugin_provider_auths", ["provider_user_id"], name: "index_oauth_plugin_provider_auths_on_provider_user_id", using: :btree

  create_table "oauth_plugin_providers", force: :cascade do |t|
    t.integer  "environment_id"
    t.string   "type",           limit: 255
    t.string   "strategy",       limit: 255
    t.string   "identifier",     limit: 255
    t.string   "name",           limit: 255
    t.string   "site",           limit: 255
    t.integer  "image_id"
    t.string   "key",            limit: 255
    t.string   "secret",         limit: 255
    t.text     "scope"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_plugin_providers", ["environment_id", "identifier"], name: "index_oauth_plugin_providers_on_environment_id_and_identifier", using: :btree
  add_index "oauth_plugin_providers", ["environment_id"], name: "index_oauth_plugin_providers_on_environment_id", using: :btree
  add_index "oauth_plugin_providers", ["identifier"], name: "index_oauth_plugin_providers_on_identifier", using: :btree
  add_index "oauth_plugin_providers", ["strategy"], name: "index_oauth_plugin_providers_on_strategy", using: :btree
  add_index "oauth_plugin_providers", ["type"], name: "index_oauth_plugin_providers_on_type", using: :btree

  create_table "open_graph_plugin_tracks", force: :cascade do |t|
    t.string   "type",             limit: 255
    t.string   "context",          limit: 255
    t.boolean  "enabled",                      default: true
    t.integer  "tracker_id"
    t.integer  "actor_id"
    t.string   "action",           limit: 255
    t.string   "object_type",      limit: 255
    t.text     "object_data_url"
    t.integer  "object_data_id"
    t.string   "object_data_type", limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.datetime "published_at"
    t.string   "story",            limit: 255
  end

  add_index "open_graph_plugin_tracks", ["action"], name: "index_open_graph_plugin_tracks_on_action", using: :btree
  add_index "open_graph_plugin_tracks", ["actor_id"], name: "index_open_graph_plugin_tracks_on_actor_id", using: :btree
  add_index "open_graph_plugin_tracks", ["context"], name: "index_open_graph_plugin_tracks_on_context", using: :btree
  add_index "open_graph_plugin_tracks", ["enabled"], name: "index_open_graph_plugin_tracks_on_enabled", using: :btree
  add_index "open_graph_plugin_tracks", ["object_data_id", "object_data_type"], name: "index_open_graph_plugin_tracks_object_data_id_type", using: :btree
  add_index "open_graph_plugin_tracks", ["object_data_url"], name: "index_open_graph_plugin_tracks_on_object_data_url", using: :btree
  add_index "open_graph_plugin_tracks", ["object_type"], name: "index_open_graph_plugin_tracks_on_object_type", using: :btree
  add_index "open_graph_plugin_tracks", ["published_at"], name: "index_open_graph_plugin_tracks_on_published_at", using: :btree
  add_index "open_graph_plugin_tracks", ["story"], name: "index_open_graph_plugin_tracks_on_story", using: :btree
  add_index "open_graph_plugin_tracks", ["type", "context"], name: "index_open_graph_plugin_tracks_on_type_and_context", using: :btree
  add_index "open_graph_plugin_tracks", ["type"], name: "index_open_graph_plugin_tracks_on_type", using: :btree

  create_table "orders_cycle_plugin_cycle_orders", force: :cascade do |t|
    t.integer  "cycle_id"
    t.integer  "sale_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_id"
  end

  add_index "orders_cycle_plugin_cycle_orders", ["cycle_id", "sale_id"], name: "index_orders_cycle_plugin_cycle_orders_on_cycle_id_and_order_id", using: :btree
  add_index "orders_cycle_plugin_cycle_orders", ["cycle_id", "sale_id"], name: "index_orders_cycle_plugin_cycle_orders_on_cycle_id_and_sale_id", using: :btree
  add_index "orders_cycle_plugin_cycle_orders", ["cycle_id"], name: "index_orders_cycle_plugin_cycle_orders_on_cycle_id", using: :btree
  add_index "orders_cycle_plugin_cycle_orders", ["purchase_id"], name: "index_orders_cycle_plugin_cycle_orders_on_purchase_id", using: :btree
  add_index "orders_cycle_plugin_cycle_orders", ["sale_id"], name: "index_orders_cycle_plugin_cycle_orders_on_order_id", using: :btree
  add_index "orders_cycle_plugin_cycle_orders", ["sale_id"], name: "index_orders_cycle_plugin_cycle_orders_on_sale_id", using: :btree

  create_table "orders_cycle_plugin_cycle_products", force: :cascade do |t|
    t.integer "cycle_id"
    t.integer "product_id"
  end

  add_index "orders_cycle_plugin_cycle_products", ["cycle_id", "product_id"], name: "orders_cycle_plugin_index_PhBVTRFB", using: :btree
  add_index "orders_cycle_plugin_cycle_products", ["cycle_id"], name: "orders_cycle_plugin_index_dqaEe7Hf", using: :btree
  add_index "orders_cycle_plugin_cycle_products", ["product_id"], name: "orders_cycle_plugin_index_f5DmQ6w5Y", using: :btree

  create_table "orders_cycle_plugin_cycles", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "name",              limit: 255
    t.text     "description"
    t.datetime "start"
    t.datetime "finish"
    t.datetime "delivery_start"
    t.datetime "delivery_finish"
    t.decimal  "margin_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",            limit: 255
    t.integer  "code"
    t.text     "opening_message"
    t.text     "data",                          default: "--- {}\n\n"
  end

  add_index "orders_cycle_plugin_cycles", ["code"], name: "index_orders_cycle_plugin_cycles_on_code", using: :btree
  add_index "orders_cycle_plugin_cycles", ["profile_id"], name: "index_distribution_plugin_sessions_on_node_id", using: :btree
  add_index "orders_cycle_plugin_cycles", ["status"], name: "index_distribution_plugin_sessions_on_status", using: :btree

  create_table "orders_plugin_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data",                                    default: "--- {}\n\n"
    t.string   "name",                        limit: 255
    t.decimal  "price"
    t.boolean  "draft"
    t.decimal  "quantity_consumer_ordered"
    t.decimal  "quantity_supplier_accepted"
    t.decimal  "quantity_supplier_separated"
    t.decimal  "quantity_supplier_delivered"
    t.decimal  "quantity_consumer_received"
    t.decimal  "price_consumer_ordered"
    t.decimal  "price_supplier_accepted"
    t.decimal  "price_supplier_separated"
    t.decimal  "price_supplier_delivered"
    t.decimal  "price_consumer_received"
    t.integer  "unit_id_consumer_ordered"
    t.integer  "unit_id_supplier_accepted"
    t.integer  "unit_id_supplier_separated"
    t.integer  "unit_id_supplier_delivered"
    t.integer  "unit_id_consumer_received"
    t.string   "type",                        limit: 255
    t.string   "status",                      limit: 255
  end

  add_index "orders_plugin_items", ["order_id"], name: "index_distribution_plugin_ordered_products_on_order_id", using: :btree
  add_index "orders_plugin_items", ["product_id"], name: "distribution_plugin_ordered_products_spid", using: :btree

  create_table "orders_plugin_orders", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "consumer_id"
    t.integer  "supplier_delivery_id"
    t.integer  "consumer_delivery_id"
    t.string   "status",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code"
    t.text     "profile_data",                       default: "--- {}\n\n"
    t.text     "consumer_data",                      default: "--- {}\n\n"
    t.text     "supplier_delivery_data",             default: "--- {}\n\n"
    t.text     "consumer_delivery_data",             default: "--- {}\n\n"
    t.text     "payment_data",                       default: "--- {}\n\n"
    t.text     "data",                               default: "--- {}\n\n"
    t.datetime "ordered_at"
    t.datetime "accepted_at"
    t.datetime "separated_at"
    t.datetime "delivered_at"
    t.datetime "received_at"
    t.string   "source",                 limit: 255
    t.string   "session_id",             limit: 255
    t.boolean  "building_next_status"
  end

  add_index "orders_plugin_orders", ["consumer_delivery_id"], name: "index_distribution_plugin_orders_on_consumer_delivery_id", using: :btree
  add_index "orders_plugin_orders", ["consumer_id"], name: "index_distribution_plugin_orders_on_consumer_id", using: :btree
  add_index "orders_plugin_orders", ["profile_id"], name: "index_distribution_plugin_orders_on_session_id", using: :btree
  add_index "orders_plugin_orders", ["session_id"], name: "index_orders_plugin_orders_on_session_id", using: :btree
  add_index "orders_plugin_orders", ["status"], name: "index_distribution_plugin_orders_on_status", using: :btree
  add_index "orders_plugin_orders", ["supplier_delivery_id"], name: "index_distribution_plugin_orders_on_supplier_delivery_id", using: :btree

  create_table "payments_plugin_payment_methods", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.text   "description", default: ""
  end

  create_table "payments_plugin_payment_methods_profiles", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "payment_method_id"
  end

  add_index "payments_plugin_payment_methods_profiles", ["profile_id"], name: "index_payments_plugin_payment_methods_profiles_on_profile_id", using: :btree

  create_table "payments_plugin_payments", force: :cascade do |t|
    t.integer  "orders_plugin_order_id"
    t.integer  "profile_id"
    t.integer  "payment_method_id"
    t.integer  "operator_id"
    t.decimal  "value"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments_plugin_payments", ["operator_id"], name: "index_payments_on_operator_id", using: :btree
  add_index "payments_plugin_payments", ["orders_plugin_order_id"], name: "index_payments_plugin_payments_on_orders_plugin_order_id", using: :btree
  add_index "payments_plugin_payments", ["payment_method_id"], name: "index_payment_methods_profiles_on_payment_method_id", using: :btree
  add_index "payments_plugin_payments", ["payment_method_id"], name: "index_payments_on_payment_method_id", using: :btree
  add_index "payments_plugin_payments", ["profile_id"], name: "index_payments_plugin_payments_on_profile_id", using: :btree

  create_table "price_details", force: :cascade do |t|
    t.decimal  "price",              default: 0.0
    t.integer  "product_id"
    t.integer  "production_cost_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "private_scraps", force: :cascade do |t|
    t.integer "person_id"
    t.integer "scrap_id"
  end

  create_table "product_qualifiers", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "qualifier_id"
    t.integer  "certifier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_qualifiers", ["certifier_id"], name: "index_product_qualifiers_on_certifier_id", using: :btree
  add_index "product_qualifiers", ["product_id"], name: "index_product_qualifiers_on_product_id", using: :btree
  add_index "product_qualifiers", ["qualifier_id"], name: "index_product_qualifiers_on_qualifier_id", using: :btree

  create_table "production_costs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "owner_id"
    t.string   "owner_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "product_category_id"
    t.string   "name",                limit: 255
    t.decimal  "price"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "discount"
    t.boolean  "available",                       default: true
    t.boolean  "highlighted",                     default: false
    t.integer  "unit_id"
    t.integer  "image_id"
    t.string   "type",                limit: 255
    t.text     "data"
    t.boolean  "archived",                        default: false
    t.float    "stored"
    t.boolean  "use_stock",                       default: false
  end

  add_index "products", ["created_at"], name: "index_products_on_created_at", using: :btree
  add_index "products", ["product_category_id"], name: "index_products_on_product_category_id", using: :btree
  add_index "products", ["profile_id"], name: "index_products_on_enterprise_id", using: :btree

  create_table "profile_activities", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "activity_id"
    t.string   "activity_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "profile_activities", ["activity_id", "activity_type"], name: "index_profile_activities_on_activity_id_and_activity_type", using: :btree
  add_index "profile_activities", ["activity_type"], name: "index_profile_activities_on_activity_type", using: :btree
  add_index "profile_activities", ["profile_id"], name: "index_profile_activities_on_profile_id", using: :btree

  create_table "profile_suggestions", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "suggestion_id"
    t.string   "suggestion_type", limit: 255
    t.text     "categories"
    t.boolean  "enabled",                     default: true
    t.float    "score",                       default: 0.0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "profile_suggestions", ["person_id"], name: "index_profile_suggestions_on_person_id", using: :btree
  add_index "profile_suggestions", ["score"], name: "index_profile_suggestions_on_score", using: :btree
  add_index "profile_suggestions", ["suggestion_id"], name: "index_profile_suggestions_on_suggestion_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "type",                    limit: 255
    t.string   "identifier",              limit: 255
    t.integer  "environment_id"
    t.boolean  "active",                              default: true
    t.string   "address",                 limit: 255
    t.string   "contact_phone",           limit: 255
    t.integer  "home_page_id"
    t.integer  "user_id"
    t.integer  "region_id"
    t.text     "data"
    t.datetime "created_at"
    t.float    "lat"
    t.float    "lng"
    t.integer  "geocode_precision"
    t.boolean  "enabled",                             default: true
    t.string   "nickname",                limit: 255
    t.text     "custom_header"
    t.text     "custom_footer"
    t.string   "theme",                   limit: 255
    t.boolean  "public_profile",                      default: true
    t.date     "birth_date"
    t.integer  "preferred_domain_id"
    t.datetime "updated_at"
    t.boolean  "visible",                             default: true
    t.integer  "image_id"
    t.integer  "bsc_id"
    t.string   "company_name",            limit: 255
    t.boolean  "validated",                           default: true
    t.string   "cnpj",                    limit: 255
    t.string   "national_region_code",    limit: 255
    t.boolean  "is_template",                         default: false
    t.integer  "template_id"
    t.string   "redirection_after_login", limit: 255
    t.integer  "friends_count",                       default: 0,          null: false
    t.integer  "members_count",                       default: 0,          null: false
    t.integer  "activities_count",                    default: 0,          null: false
    t.string   "personal_website",        limit: 255
    t.string   "jabber_id",               limit: 255
    t.string   "usp_id",                  limit: 255
    t.integer  "welcome_page_id"
    t.boolean  "allow_members_to_invite",             default: true
    t.boolean  "invite_friends_only",                 default: false
    t.boolean  "secret",                              default: false
    t.string   "editor",                              default: "tiny_mce", null: false
    t.integer  "top_image_id"
  end

  add_index "profiles", ["activities_count"], name: "index_profiles_on_activities_count", using: :btree
  add_index "profiles", ["created_at"], name: "index_profiles_on_created_at", using: :btree
  add_index "profiles", ["enabled"], name: "index_profiles_on_enabled", using: :btree
  add_index "profiles", ["environment_id"], name: "index_profiles_on_environment_id", using: :btree
  add_index "profiles", ["friends_count"], name: "index_profiles_on_friends_count", using: :btree
  add_index "profiles", ["identifier"], name: "index_profiles_on_identifier", using: :btree
  add_index "profiles", ["members_count"], name: "index_profiles_on_members_count", using: :btree
  add_index "profiles", ["region_id"], name: "index_profiles_on_region_id", using: :btree
  add_index "profiles", ["type"], name: "index_profiles_on_type", using: :btree
  add_index "profiles", ["user_id", "type"], name: "index_profiles_on_user_id_and_type", using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  add_index "profiles", ["validated"], name: "index_profiles_on_validated", using: :btree
  add_index "profiles", ["visible"], name: "index_profiles_on_visible", using: :btree

  create_table "profiles_circles", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "circle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles_circles", ["profile_id", "circle_id"], name: "profiles_circles_composite_key_index", unique: true, using: :btree

  create_table "qualifier_certifiers", force: :cascade do |t|
    t.integer "qualifier_id"
    t.integer "certifier_id"
  end

  create_table "qualifiers", force: :cascade do |t|
    t.string   "name",           limit: 255, null: false
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
  end

  create_table "refused_join_community", id: false, force: :cascade do |t|
    t.integer "person_id"
    t.integer "community_id"
  end

  create_table "region_validators", id: false, force: :cascade do |t|
    t.integer "region_id"
    t.integer "organization_id"
  end

  create_table "reported_images", force: :cascade do |t|
    t.integer "size"
    t.string  "content_type",    limit: 255
    t.string  "filename",        limit: 255
    t.integer "height"
    t.integer "width"
    t.integer "abuse_report_id"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.integer  "accessor_id",               null: false
    t.string   "accessor_type", limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.integer  "role_id",                   null: false
    t.boolean  "is_global"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_assignments", ["accessor_id", "accessor_type"], name: "index_role_assignments_on_accessor_id_and_accessor_type", using: :btree
  add_index "role_assignments", ["resource_id", "resource_type"], name: "index_role_assignments_on_resource_id_and_resource_type", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.text    "permissions"
    t.string  "key",            limit: 255
    t.boolean "system",                     default: false
    t.integer "environment_id"
    t.integer "profile_id"
  end

  create_table "scraps", force: :cascade do |t|
    t.text     "content"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "scrap_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_term_occurrences", force: :cascade do |t|
    t.integer  "search_term_id"
    t.datetime "created_at"
    t.integer  "total",          default: 0
    t.integer  "indexed",        default: 0
  end

  add_index "search_term_occurrences", ["created_at"], name: "index_search_term_occurrences_on_created_at", using: :btree

  create_table "search_terms", force: :cascade do |t|
    t.string  "term",             limit: 255
    t.integer "context_id"
    t.string  "context_type",     limit: 255
    t.string  "asset",            limit: 255, default: "all"
    t.float   "score",                        default: 0.0
    t.float   "relevance_score",              default: 0.0
    t.float   "occurrence_score",             default: 0.0
  end

  add_index "search_terms", ["asset"], name: "index_search_terms_on_asset", using: :btree
  add_index "search_terms", ["occurrence_score"], name: "index_search_terms_on_occurrence_score", using: :btree
  add_index "search_terms", ["relevance_score"], name: "index_search_terms_on_relevance_score", using: :btree
  add_index "search_terms", ["score"], name: "index_search_terms_on_score", using: :btree
  add_index "search_terms", ["term"], name: "index_search_terms_on_term", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "shopping_cart_plugin_purchase_orders", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "seller_id"
    t.text     "data"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "smssync_plugin_messages", force: :cascade do |t|
    t.string   "uuid",            limit: 255
    t.integer  "chat_message_id"
    t.integer  "from_profile_id"
    t.integer  "to_profile_id"
    t.string   "from",            limit: 255
    t.string   "sent_to",         limit: 255
    t.string   "device_id",       limit: 255
    t.text     "message"
    t.datetime "sent_timestamp"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "sniffer_plugin_opportunities", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "opportunity_id"
    t.string   "opportunity_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "sniffer_plugin_profiles", force: :cascade do |t|
    t.integer  "profile_id"
    t.boolean  "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_plugin_allocations", force: :cascade do |t|
    t.integer  "place_id"
    t.integer  "product_id"
    t.decimal  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "stock_plugin_allocations", ["place_id", "product_id"], name: "index_stock_plugin_allocations_on_place_id_and_product_id", using: :btree
  add_index "stock_plugin_allocations", ["place_id"], name: "index_stock_plugin_allocations_on_place_id", using: :btree
  add_index "stock_plugin_allocations", ["product_id"], name: "index_stock_plugin_allocations_on_product_id", using: :btree

  create_table "stock_plugin_allocations_orders", force: :cascade do |t|
    t.integer "order_id"
    t.integer "stock_allocation_id"
  end

  create_table "stock_plugin_places", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_plugin_places", ["profile_id"], name: "index_stock_plugin_places_on_profile_id", using: :btree

  create_table "sub_organizations_plugin_approve_paternity_relations", force: :cascade do |t|
    t.integer "task_id"
    t.integer "parent_id"
    t.string  "parent_type", limit: 255
    t.integer "child_id"
    t.string  "child_type",  limit: 255
  end

  create_table "sub_organizations_plugin_relations", force: :cascade do |t|
    t.integer "parent_id"
    t.string  "parent_type", limit: 255
    t.integer "child_id"
    t.string  "child_type",  limit: 255
  end

  create_table "suggestion_connections", force: :cascade do |t|
    t.integer "suggestion_id",               null: false
    t.integer "connection_id",               null: false
    t.string  "connection_type", limit: 255, null: false
  end

  create_table "suppliers_plugin_hubs", force: :cascade do |t|
    t.string  "name"
    t.string  "description"
    t.integer "profile_id"
  end

  add_index "suppliers_plugin_hubs", ["profile_id"], name: "index_suppliers_plugin_hubs_on_profile_id", using: :btree

  create_table "suppliers_plugin_source_products", force: :cascade do |t|
    t.integer  "from_product_id"
    t.integer  "to_product_id"
    t.decimal  "quantity",        default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
  end

  add_index "suppliers_plugin_source_products", ["from_product_id", "to_product_id"], name: "suppliers_plugin_index_dtBULzU3", using: :btree
  add_index "suppliers_plugin_source_products", ["from_product_id"], name: "index_distribution_plugin_source_products_on_from_product_id", using: :btree
  add_index "suppliers_plugin_source_products", ["supplier_id", "from_product_id", "to_product_id"], name: "suppliers_plugin_index_VBNqyeCP", using: :btree
  add_index "suppliers_plugin_source_products", ["supplier_id", "from_product_id"], name: "suppliers_plugin_index_naHsVLS6cH", using: :btree
  add_index "suppliers_plugin_source_products", ["supplier_id"], name: "suppliers_plugin_index_Lm5QPpV8", using: :btree
  add_index "suppliers_plugin_source_products", ["to_product_id"], name: "index_distribution_plugin_source_products_on_to_product_id", using: :btree

  create_table "suppliers_plugin_suppliers", force: :cascade do |t|
    t.integer  "consumer_id"
    t.string   "name",              limit: 255
    t.string   "name_abbreviation", limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
    t.boolean  "active",                        default: true
    t.string   "qualifiers",        limit: 255
    t.string   "tags",              limit: 255
    t.string   "lat",               limit: 255
    t.string   "lng",               limit: 255
    t.string   "phone"
    t.string   "cell_phone"
    t.string   "email"
    t.integer  "hub_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
  end

  add_index "suppliers_plugin_suppliers", ["consumer_id"], name: "index_distribution_plugin_suppliers_on_consumer_id", using: :btree
  add_index "suppliers_plugin_suppliers", ["hub_id"], name: "index_suppliers_plugin_suppliers_on_hub_id", using: :btree
  add_index "suppliers_plugin_suppliers", ["profile_id", "consumer_id"], name: "index_suppliers_plugin_suppliers_on_profile_id_and_consumer_id", using: :btree
  add_index "suppliers_plugin_suppliers", ["profile_id"], name: "index_suppliers_plugin_suppliers_on_profile_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "parent_id"
    t.boolean "pending",                    default: false
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["parent_id"], name: "index_tags_on_parent_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.text     "data"
    t.integer  "status"
    t.datetime "end_date"
    t.integer  "requestor_id"
    t.integer  "target_id"
    t.string   "code",           limit: 40
    t.string   "type",           limit: 255
    t.datetime "created_at"
    t.string   "target_type",    limit: 255
    t.integer  "image_id"
    t.integer  "bsc_id"
    t.boolean  "spam",                       default: false
    t.integer  "responsible_id"
    t.integer  "closed_by_id"
  end

  add_index "tasks", ["requestor_id"], name: "index_tasks_on_requestor_id", using: :btree
  add_index "tasks", ["spam"], name: "index_tasks_on_spam", using: :btree
  add_index "tasks", ["status"], name: "index_tasks_on_status", using: :btree
  add_index "tasks", ["target_id", "target_type"], name: "index_tasks_on_target_id_and_target_type", using: :btree
  add_index "tasks", ["target_id"], name: "index_tasks_on_target_id", using: :btree
  add_index "tasks", ["target_type"], name: "index_tasks_on_target_type", using: :btree

  create_table "terms_forum_people", id: false, force: :cascade do |t|
    t.integer "forum_id"
    t.integer "person_id"
  end

  add_index "terms_forum_people", ["forum_id", "person_id"], name: "index_terms_forum_people_on_forum_id_and_person_id", using: :btree

  create_table "thumbnails", force: :cascade do |t|
    t.integer "size"
    t.string  "content_type", limit: 255
    t.string  "filename",     limit: 255
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string  "thumbnail",    limit: 255
  end

  add_index "thumbnails", ["parent_id"], name: "index_thumbnails_on_parent_id", using: :btree

  create_table "units", force: :cascade do |t|
    t.string  "singular",       limit: 255, null: false
    t.string  "plural",         limit: 255, null: false
    t.integer "position"
    t.integer "environment_id",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                      limit: 255
    t.string   "email",                      limit: 255
    t.string   "crypted_password",           limit: 40
    t.string   "salt",                       limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",             limit: 255
    t.datetime "remember_token_expires_at"
    t.text     "terms_of_use"
    t.string   "terms_accepted",             limit: 1
    t.integer  "environment_id"
    t.string   "password_type",              limit: 255
    t.boolean  "enable_email",                           default: false
    t.string   "last_chat_status",           limit: 255, default: ""
    t.string   "chat_status",                limit: 255, default: ""
    t.datetime "chat_status_at"
    t.string   "activation_code",            limit: 40
    t.datetime "activated_at"
    t.string   "return_to",                  limit: 255
    t.datetime "last_login_at"
    t.string   "private_token"
    t.datetime "private_token_generated_at"
  end

  create_table "validation_infos", force: :cascade do |t|
    t.text    "validation_methodology"
    t.text    "restrictions"
    t.integer "organization_id"
  end

  create_table "volunteers_plugin_assignments", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "period_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "volunteers_plugin_assignments", ["period_id"], name: "index_volunteers_plugin_assignments_on_period_id", using: :btree
  add_index "volunteers_plugin_assignments", ["profile_id", "period_id"], name: "index_volunteers_plugin_assignments_on_profile_id_and_period_id", using: :btree
  add_index "volunteers_plugin_assignments", ["profile_id"], name: "index_volunteers_plugin_assignments_on_profile_id", using: :btree

  create_table "volunteers_plugin_periods", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type",         limit: 255
    t.text     "name"
    t.datetime "start"
    t.datetime "end"
    t.integer  "minimum_assigments"
    t.integer  "maximum_assigments"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "volunteers_plugin_periods", ["owner_id", "owner_type"], name: "index_volunteers_plugin_periods_on_owner_id_and_owner_type", using: :btree
  add_index "volunteers_plugin_periods", ["owner_type"], name: "index_volunteers_plugin_periods_on_owner_type", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "vote",                      null: false
    t.integer  "voteable_id",               null: false
    t.string   "voteable_type", limit: 255, null: false
    t.integer  "voter_id"
    t.string   "voter_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], name: "fk_voteables", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "fk_voters", using: :btree

  add_foreign_key "payments_plugin_payments", "orders_plugin_orders"
  add_foreign_key "payments_plugin_payments", "profiles"
  add_foreign_key "profiles_circles", "circles", on_delete: :cascade
  add_foreign_key "suppliers_plugin_hubs", "profiles"
end
