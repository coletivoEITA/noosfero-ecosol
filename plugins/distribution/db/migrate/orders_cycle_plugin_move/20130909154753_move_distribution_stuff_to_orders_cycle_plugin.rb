class DistributionPlugin::Node < Noosfero::Plugin::ActiveRecord
  belongs_to :profile
end

class MoveDistributionStuffToOrdersCyclePlugin < ActiveRecord::Migration
  def self.up
    rename_table :distribution_plugin_sessions, :orders_cycle_plugin_cycles
    rename_table :distribution_plugin_session_products, :orders_cycle_plugin_cycle_products
    rename_table :distribution_plugin_session_orders, :orders_cycle_plugin_cycle_orders

    rename_column :orders_cycle_plugin_cycle_orders, :session_id, :cycle_id
    rename_column :orders_cycle_plugin_cycle_products, :session_id, :cycle_id

    Product.update_all ["type = 'OrdersCyclePlugin::OfferedProduct'"], "type = 'DistributionPluginOfferedProduct'"
    DeliveryPlugin::Option.update_all ["owner_type = 'OrdersCyclePlugin::Cycle'"]
  end

  def self.down
    say "this migration can't be reverted"
  end
end
