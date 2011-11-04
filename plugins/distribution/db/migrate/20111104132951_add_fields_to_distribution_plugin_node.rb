class AddFieldsToDistributionPluginNode < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_nodes, :enabled, :boolean
    add_column :distribution_plugin_nodes, :image_id, :integer
    add_column :distribution_plugin_nodes, :name_abbreviation, :string
  end

  def self.down
    remove_column :distribution_plugin_nodes, :name_abbreviation
    remove_column :distribution_plugin_nodes, :image_id
    remove_column :distribution_plugin_nodes, :enabled
  end
end
