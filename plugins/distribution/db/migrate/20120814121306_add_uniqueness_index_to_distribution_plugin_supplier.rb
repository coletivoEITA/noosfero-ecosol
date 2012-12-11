class AddUniquenessIndexToDistributionPluginSupplier < ActiveRecord::Migration
  def self.up
    add_index :distribution_plugin_suppliers, [ :node_id, :consumer_id ], :unique => true
  end

  def self.down
    remove_index :distribution_plugin_suppliers, [ :node_id, :consumer_id ], :unique => true
  end
end
