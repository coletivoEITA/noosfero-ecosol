class CreateDistributionPluginOrderedProducts < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_ordered_products do |t|
      t.integer :session_product_id
      t.integer :order_id
      t.decimal :quantity_asked
      t.decimal :quantity_allocated
      t.decimal :quantity_payed

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_plugin_ordered_products
  end
end
