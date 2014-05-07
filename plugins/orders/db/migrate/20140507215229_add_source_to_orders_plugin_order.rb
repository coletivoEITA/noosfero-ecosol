class AddSourceToOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_orders, :source, :string
    OrdersPlugin::Order.find_each do |order|
      next unless order.consumer_delivery_data.present? or order.payment_data.present?
      order.source = 'shopping_cart_plugin'
      order.send :update_without_callbacks
    end
  end

  def self.down
  end
end
