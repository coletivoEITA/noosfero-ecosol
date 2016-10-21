class CreateStockPluginAllocationsOrders < ActiveRecord::Migration
  def change
    create_table :stock_plugin_allocations_orders do |t|
      t.references :order
      t.references :stock_allocation
    end
  end
end
