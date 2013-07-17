class AddMarginsToDistributionPluginNode < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_nodes, :margin_percentage, :decimal
    add_column :distribution_plugin_nodes, :margin_fixed, :decimal
  end

  def self.down
    remove_column :distribution_plugin_nodes, :margin_fixed
    remove_column :distribution_plugin_nodes, :margin_percentage
  end
end
