class RefactorOrdersCyclePluginCycleOrder < ActiveRecord::Migration
  def self.up
    rename_column :orders_cycle_plugin_cycle_orders, :order_id, :sale_id
    add_column :orders_cycle_plugin_cycle_orders, :purchase_id, :integer

    add_index :orders_cycle_plugin_cycle_orders, :cycle_id
    add_index :orders_cycle_plugin_cycle_orders, :sale_id
    add_index :orders_cycle_plugin_cycle_orders, :purchase_id
    add_index :orders_cycle_plugin_cycle_orders, [:cycle_id, :sale_id]
    add_index :orders_cycle_plugin_cycle_orders, [:cycle_id, :purchase_id]
  end

  def self.down
    say "this migration can't be reverted"
  end
end
