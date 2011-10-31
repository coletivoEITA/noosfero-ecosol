class AddTypeToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_products, :type, :string
  end

  def self.down
    remove_column :distribution_plugin_products, :type
  end
end
