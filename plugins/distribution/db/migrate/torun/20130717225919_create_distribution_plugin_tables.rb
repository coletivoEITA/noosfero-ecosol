class CreateDistributionPluginTables < ActiveRecord::Migration
  def self.up
    # check for old migrations
    return if ActiveRecord::Base.connection.table_exists? "distribution_plugin_nodes"

    create_table "distribution_plugin_delivery_methods", :force => true do |t|
      t.integer  "node_id"
      t.string   "name"
      t.text     "description"
      t.string   "recipient"
      t.string   "address_line1"
      t.string   "address_line2"
      t.string   "postal_code"
      t.string   "state"
      t.string   "country"
      t.string   "delivery_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "distribution_plugin_delivery_methods", ["node_id"], :name => "index_distribution_plugin_delivery_methods_on_node_id"

    create_table "distribution_plugin_delivery_options", :force => true do |t|
      t.integer  "session_id"
      t.integer  "delivery_method_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "distribution_plugin_delivery_options", ["delivery_method_id"], :name => "distribution_plugin_delivery_options_dmid"
    add_index "distribution_plugin_delivery_options", ["session_id", "delivery_method_id"], :name => "distribution_plugin_delivery_options_sid_dmid"
    add_index "distribution_plugin_delivery_options", ["session_id"], :name => "index_distribution_plugin_delivery_options_on_session_id"

    create_table "distribution_plugin_nodes", :force => true do |t|
      t.integer  "profile_id"
      t.string   "role"
      t.text     "features"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "margin_percentage"
      t.decimal  "margin_fixed"
      t.boolean  "enabled"
      t.integer  "image_id"
      t.string   "name_abbreviation"
      t.string   "header_type"
      t.string   "header_fg_color"
      t.string   "header_bg_color"
    end

    add_index "distribution_plugin_nodes", ["profile_id"], :name => "index_distribution_plugin_nodes_on_profile_id"

    create_table "distribution_plugin_ordered_products", :force => true do |t|
      t.integer  "product_id"
      t.integer  "order_id"
      t.decimal  "quantity_asked",     :default => 0.0
      t.decimal  "quantity_allocated", :default => 0.0
      t.decimal  "quantity_payed",     :default => 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "price_asked",        :default => 0.0
      t.decimal  "price_allocated",    :default => 0.0
      t.decimal  "price_payed",        :default => 0.0
    end

    add_index "distribution_plugin_ordered_products", ["order_id"], :name => "index_distribution_plugin_ordered_products_on_order_id"
    add_index "distribution_plugin_ordered_products", ["product_id"], :name => "distribution_plugin_ordered_products_spid"

    create_table "distribution_plugin_orders", :force => true do |t|
      t.integer  "session_id"
      t.integer  "consumer_id"
      t.integer  "supplier_delivery_id"
      t.integer  "consumer_delivery_id"
      t.decimal  "total_collected"
      t.decimal  "total_payed"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "code"
    end

    add_index "distribution_plugin_orders", ["consumer_delivery_id"], :name => "index_distribution_plugin_orders_on_consumer_delivery_id"
    add_index "distribution_plugin_orders", ["consumer_id"], :name => "index_distribution_plugin_orders_on_consumer_id"
    add_index "distribution_plugin_orders", ["session_id"], :name => "index_distribution_plugin_orders_on_session_id"
    add_index "distribution_plugin_orders", ["status"], :name => "index_distribution_plugin_orders_on_status"
    add_index "distribution_plugin_orders", ["supplier_delivery_id"], :name => "index_distribution_plugin_orders_on_supplier_delivery_id"

    create_table "distribution_plugin_session_products", :force => true do |t|
      t.integer "session_id"
      t.integer "product_id"
    end

    create_table "distribution_plugin_sessions", :force => true do |t|
      t.integer  "node_id"
      t.string   "name"
      t.text     "description"
      t.datetime "start"
      t.datetime "finish"
      t.datetime "delivery_start"
      t.datetime "delivery_finish"
      t.decimal  "margin_percentage"
      t.decimal  "margin_fixed",      :default => 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status"
      t.integer  "code"
      t.text     "opening_message"
    end

    add_index "distribution_plugin_sessions", ["node_id"], :name => "index_distribution_plugin_sessions_on_node_id"
    add_index "distribution_plugin_sessions", ["status"], :name => "index_distribution_plugin_sessions_on_status"

  end

  def self.down
  end
end
