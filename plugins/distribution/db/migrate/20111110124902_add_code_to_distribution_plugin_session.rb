class AddCodeToDistributionPluginSession < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_sessions, :code, :integer
    add_column :distribution_plugin_orders, :code, :integer
  end

  def self.down
    remove_column :distribution_plugin_sessions, :code
    remove_column :distribution_plugin_orders, :code
  end
end
