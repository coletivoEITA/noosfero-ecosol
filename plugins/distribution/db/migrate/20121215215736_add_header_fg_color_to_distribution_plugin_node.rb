class AddHeaderFgColorToDistributionPluginNode < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_nodes, :header_fg_color, :string
  end

  def self.down
    remove_column :distribution_plugin_nodes, :header_fg_color
  end
end
