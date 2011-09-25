class AddSettingsToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_products, :settings, :text
  end

  def self.down
    remove_column :distribution_plugin_products, :settings
  end
end
