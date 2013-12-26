class MoveShoppingCartPurchaseOrderToOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    ShoppingCartPlugin::PurchaseOrder.find_each do |purchase_order|
      data = purchase_order.data

      order = OrdersPlugin::Order.new :profile_id => purchase_order.seller_id, :consumer_id => purchase_order.customer_id

      order.consumer_data = {}
      ['contact_phone','name','email'].each do |prop|
        order.consumer_data[prop.to_sym] = data[('customer_'+prop).to_sym]
      end

      order.consumer_delivery_data = {
        :name           => data[:customer_delivery_option],
        :address_line1  => data[:customer_address],
        :address_line2  => data[:customer_district],
        :postal_code    => data[:customer_zip_code],
        :state          => data[:customer_state],
        :country        => 'Brasil'
      }
      order.supplier_delivery_data = {}

      order.products_data = data[:products_list]
      order.payment_data = {
        :method         => data[:customer_payment],
        :change         => data[:customer_change]
      }

      status_transform = {
        ShoppingCartPlugin::PurchaseOrder::Status::OPENED => 'confirmed',
        ShoppingCartPlugin::PurchaseOrder::Status::CONFIRMED => 'accepted',
        ShoppingCartPlugin::PurchaseOrder::Status::CANCELED => 'cancelled',
        ShoppingCartPlugin::PurchaseOrder::Status::SHIPPED => 'shipped',
      }
      order.status = status_transform[purchase_order.status]

      order.save!
      pp purchase_order
      pp order
    end
    drop_table :shopping_cart_plugin_purchase_orders
  end

  def self.down
  end
end
