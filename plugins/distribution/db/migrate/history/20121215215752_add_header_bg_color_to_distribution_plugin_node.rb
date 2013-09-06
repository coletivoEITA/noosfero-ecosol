class AddHeaderBgColorToDistributionPluginNode < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_nodes, :header_bg_color, :string
  end

  def self.down
    remove_column :distribution_plugin_nodes, :header_bg_color
  end
end
