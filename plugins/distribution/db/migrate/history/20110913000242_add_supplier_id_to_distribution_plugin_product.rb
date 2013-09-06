class AddSupplierIdToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_products, :supplier_id, :integer
  end

  def self.down
    remove_column :distribution_plugin_products, :supplier_id
  end
end
