class CreateSuppliersPluginSourceProduct < ActiveRecord::Migration
  def self.up
    # check if distribution plugin already moved the table
    return if ActiveRecord::Base.connection.table_exists? "suppliers_plugin_source_products"

    create_table :suppliers_plugin_source_products do |t|
      t.integer  "from_product_id"
      t.integer  "to_product_id"
      t.integer  "supplier_id"
      t.decimal  "quantity", :default => 0.0
      t.timestamps
    end
  end

  def self.down
    drop_table :suppliers_plugin_source_products
  end
end
