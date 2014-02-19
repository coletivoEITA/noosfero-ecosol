class AddSerializedFieldsToOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_orders, :profile_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :consumer_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :supplier_delivery_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :consumer_delivery_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :payment_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :products_data, :text, :default => {}.to_yaml
    add_column :orders_plugin_orders, :data, :text, :default => {}.to_yaml
  end

  def self.down
    say "this migration can't be reverted"
  end
end
