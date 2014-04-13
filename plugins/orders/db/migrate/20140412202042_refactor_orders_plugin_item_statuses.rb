class RefactorOrdersPluginItemStatuses < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_items, :draft, :boolean

    add_column :orders_plugin_items, :quantity_consumer_asked, :decimal
    add_column :orders_plugin_items, :quantity_supplier_accepted, :decimal
    add_column :orders_plugin_items, :quantity_supplier_separated, :decimal
    add_column :orders_plugin_items, :quantity_supplier_delivered, :decimal
    add_column :orders_plugin_items, :quantity_consumer_received, :decimal
    add_column :orders_plugin_items, :price_consumer_asked, :decimal
    add_column :orders_plugin_items, :price_supplier_accepted, :decimal
    add_column :orders_plugin_items, :price_supplier_separated, :decimal
    add_column :orders_plugin_items, :price_supplier_delivered, :decimal
    add_column :orders_plugin_items, :price_consumer_received, :decimal

    OrdersPlugin::Item.reset_column_information
    OrdersPlugin::Item.record_timestamps = false
    OrdersPlugin::Item.find_each do |order|
      order.quantity_consumer_asked = order.quantity_asked
      order.quantity_supplier_accepted = order.quantity_accepted
      order.quantity_supplier_delivered = order.quantity_shipped
      order.price_consumer_asked = order.price_consumer_asked
      order.price_supplier_accepted = order.price_accepted
      order.price_supplier_delivered = order.price_shipped
      order.send :update_without_callbacks
    end

    remove_column :orders_plugin_items, :quantity_asked
    remove_column :orders_plugin_items, :quantity_accepted
    remove_column :orders_plugin_items, :quantity_shipped
    remove_column :orders_plugin_items, :price_asked
    remove_column :orders_plugin_items, :price_accepted
    remove_column :orders_plugin_items, :price_shipped
  end

  def self.down
    say "this migration can't be reverted"
  end
end
