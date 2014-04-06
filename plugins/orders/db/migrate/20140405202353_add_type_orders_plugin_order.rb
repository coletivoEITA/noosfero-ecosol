class AddTypeOrdersPluginOrder < ActiveRecord::Migration
  def self.up
    add_column :orders_plugin_orders, :type, :string
    ActiveRecord::Base.connection.execute "UPDATE orders_plugin_orders SET type = 'OrdersPlugin::Sale'"
  end

  def self.down
    remove_column :orders_plugin_orders, :type
  end
end
