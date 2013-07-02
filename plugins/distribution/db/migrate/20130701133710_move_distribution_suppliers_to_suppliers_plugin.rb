class MoveDistributionSuppliersToSuppliersPlugin < ActiveRecord::Migration

  def self.up
    rename_table :distribution_plugin_suppliers, :suppliers_plugin_suppliers
  end

  def self.down
  end

end
