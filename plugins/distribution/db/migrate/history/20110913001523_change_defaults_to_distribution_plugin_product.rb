class ChangeDefaultsToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    change_column_default :distribution_plugin_products, :deleted, false
    rename_column :distribution_plugin_products, :deleted, :archived
    change_column_default :distribution_plugin_products, :active, true
  end

  def self.down
    rename_column :distribution_plugin_products, :archived, :deleted
  end
end
