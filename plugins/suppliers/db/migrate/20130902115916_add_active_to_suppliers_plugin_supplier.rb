class AddActiveToSuppliersPluginSupplier < ActiveRecord::Migration
  def self.up
    add_column :suppliers_plugin_suppliers, :active, :string
  end

  def self.down
    remove_column :suppliers_plugin_suppliers, :active
  end
end
