class OrdersCyclePluginIndexFilteredFields < ActiveRecord::Migration
  def self.up
    add_index :orders_cycle_plugin_cycle_orders, [:cycle_id]
    add_index :orders_cycle_plugin_cycle_orders, [:order_id]
    add_index :orders_cycle_plugin_cycle_orders, [:cycle_id, :order_id]

    add_index :orders_cycle_plugin_cycle_products, [:cycle_id]
    add_index :orders_cycle_plugin_cycle_products, [:product_id]
    add_index :orders_cycle_plugin_cycle_products, [:cycle_id, :product_id]

    add_index :orders_cycle_plugin_cycles, [:code]
  end

  def self.down
    say "this migration can't be reverted"
  end
end
