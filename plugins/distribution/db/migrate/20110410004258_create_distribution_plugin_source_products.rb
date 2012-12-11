class CreateDistributionPluginSourceProducts < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_source_products do |t|
      t.integer :from_product_id
      t.integer :to_product_id
      t.decimal :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_plugin_source_products
  end
end
