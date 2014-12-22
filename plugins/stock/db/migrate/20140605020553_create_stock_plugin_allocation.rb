class CreateStockPluginAllocation < ActiveRecord::Migration
  def self.up
    create_table :stock_plugin_allocations do |t|
      t.integer :place_id
      t.integer :product_id
      t.decimal :quantity

      t.timestamps
    end
    add_index :stock_plugin_allocations, :place_id
    add_index :stock_plugin_allocations, :product_id
    add_index :stock_plugin_allocations, [:place_id, :product_id]
  end

  def self.down
    drop_table :stock_plugin_allocations
  end
end
