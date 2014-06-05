class CreateStockPluginPlaceProduct < ActiveRecord::Migration
  def self.up
    create_table :stock_plugin_place_products do |t|
      t.integer :place_id
      t.integer :product_id
      t.decimal :quantity

      t.timestamps
    end
    add_index :stock_plugin_place_products, :place_id
    add_index :stock_plugin_place_products, :product_id
    add_index :stock_plugin_place_products, [:place_id, :product_id]
  end

  def self.down
    drop_table :stock_plugin_place_products
  end
end
