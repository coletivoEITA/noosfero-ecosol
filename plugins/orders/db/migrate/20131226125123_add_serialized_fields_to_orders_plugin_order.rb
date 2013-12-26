class AddSerializedFieldsToOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_orders, :consumer_data, :text
    add_column :orders_plugin_orders, :supplier_delivery_data, :text
    add_column :orders_plugin_orders, :consumer_delivery_data, :text
    add_column :orders_plugin_orders, :payment_data, :text
    add_column :orders_plugin_orders, :products_data, :text
    add_column :orders_plugin_orders, :data, :text
  end

  def self.down
  end
end
