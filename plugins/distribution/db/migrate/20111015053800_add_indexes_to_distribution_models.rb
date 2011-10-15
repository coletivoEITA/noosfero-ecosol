class AddIndexesToDistributionModels < ActiveRecord::Migration
  def self.up
    add_index :distribution_plugin_delivery_methods, :node_id
    add_index :distribution_plugin_products, :supplier_id
    add_index :distribution_plugin_products, :session_id
    add_index :distribution_plugin_products, :product_id
    add_index :distribution_plugin_products, :node_id
    add_index :distribution_plugin_products, :unit_id
    add_index :distribution_plugin_products, :archived
    add_index :distribution_plugin_source_products, :from_product_id
    add_index :distribution_plugin_source_products, :to_product_id
    add_index :distribution_plugin_ordered_products, :session_product_id
    add_index :distribution_plugin_ordered_products, :order_id
    add_index :distribution_plugin_nodes, :profile_id
    add_index :distribution_plugin_delivery_options, :session_id
    add_index :distribution_plugin_delivery_options, :delivery_method_id
    add_index :distribution_plugin_delivery_options, [:session_id, :delivery_method_id]
    add_index :distribution_plugin_sessions, :node_id
    add_index :distribution_plugin_sessions, :status
    add_index :distribution_plugin_suppliers, :node_id
    add_index :distribution_plugin_suppliers, :consumer_id
    add_index :distribution_plugin_orders, :session_id
    add_index :distribution_plugin_orders, :consumer_id
    add_index :distribution_plugin_orders, :supplier_delivery_id
    add_index :distribution_plugin_orders, :consumer_delivery_id
    add_index :distribution_plugin_orders, :status
  end

  def self.down
    remove_index :distribution_plugin_delivery_methods, :node_id
    remove_index :distribution_plugin_products, :supplier_id
    remove_index :distribution_plugin_products, :session_id
    remove_index :distribution_plugin_products, :product_id
    remove_index :distribution_plugin_products, :node_id
    remove_index :distribution_plugin_products, :unit_id
    remove_index :distribution_plugin_products, :archived
    remove_index :distribution_plugin_source_products, :from_product_id
    remove_index :distribution_plugin_source_products, :to_product_id
    remove_index :distribution_plugin_ordered_products, :session_product_id
    remove_index :distribution_plugin_ordered_products, :order_id
    remove_index :distribution_plugin_nodes, :profile_id
    remove_index :distribution_plugin_delivery_options, :session_id
    remove_index :distribution_plugin_delivery_options, :delivery_method_id
    remove_index :distribution_plugin_delivery_options, [:session_id, :delivery_method_id]
    remove_index :distribution_plugin_sessions, :node_id
    remove_index :distribution_plugin_sessions, :status
    remove_index :distribution_plugin_suppliers, :node_id
    remove_index :distribution_plugin_suppliers, :consumer_id
    remove_index :distribution_plugin_orders, :session_id
    remove_index :distribution_plugin_orders, :consumer_id
    remove_index :distribution_plugin_orders, :supplier_delivery_id
    remove_index :distribution_plugin_orders, :consumer_delivery_id
    remove_index :distribution_plugin_orders, :status
  end
end
