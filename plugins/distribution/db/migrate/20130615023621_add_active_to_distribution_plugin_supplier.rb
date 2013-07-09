class AddActiveToDistributionPluginSupplier < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_suppliers, :active, :string
  end

  def self.down
    remove_column :distribution_plugin_suppliers, :active
  end
end
