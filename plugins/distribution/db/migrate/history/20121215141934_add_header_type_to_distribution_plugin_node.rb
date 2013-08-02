class AddHeaderTypeToDistributionPluginNode < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_nodes, :header_type, :string
  end

  def self.down
    remove_column :distribution_plugin_nodes, :header_type
  end
end
