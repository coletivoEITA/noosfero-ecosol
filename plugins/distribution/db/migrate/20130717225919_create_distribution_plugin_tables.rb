class CreateDistributionPluginTables < ActiveRecord::Migration
  def self.up
    # check for old migrations
    return if ActiveRecord::Base.connection.table_exists? "distribution_plugin_nodes"

    create_table "distribution_plugin_nodes" do |t|
      t.integer  "profile_id"
      t.string   "role"
      t.text     "features"
      t.decimal  "margin_percentage"
      t.decimal  "margin_fixed"
      t.boolean  "enabled"
      t.integer  "image_id"
      t.string   "name_abbreviation"
      t.string   "header_type"
      t.string   "header_fg_color"
      t.string   "header_bg_color"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "distribution_plugin_nodes", ["profile_id"]

    create_table "distribution_plugin_session_orders" do |t|
      t.integer  "session_id"
      t.integer  "order_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "distribution_plugin_session_orders", ["session_id"]
    add_index "distribution_plugin_session_orders", ["order_id"]

    create_table "distribution_plugin_session_products" do |t|
      t.integer "session_id"
      t.integer "product_id"
    end

    add_index "distribution_plugin_session_products", ["session_id"]
    add_index "distribution_plugin_session_products", ["product_id"]

    create_table "distribution_plugin_sessions" do |t|
      t.integer  "node_id"
      t.string   "name"
      t.text     "description"
      t.datetime "start"
      t.datetime "finish"
      t.datetime "delivery_start"
      t.datetime "delivery_finish"
      t.decimal  "margin_percentage"
      t.decimal  "margin_fixed",      :default => 0.0
      t.string   "status"
      t.integer  "code"
      t.text     "opening_message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "distribution_plugin_sessions", ["node_id"]
    add_index "distribution_plugin_sessions", ["status"]

  end

  def self.down
    drop_table "distribution_plugin_nodes"
    drop_table "distribution_plugin_session_orders"
    drop_table "distribution_plugin_session_products"
    drop_table "distribution_plugin_sessions"
  end
end
