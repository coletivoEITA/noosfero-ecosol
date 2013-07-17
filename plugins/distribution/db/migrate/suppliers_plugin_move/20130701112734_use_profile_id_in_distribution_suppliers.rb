class DistributionPluginNode < ActiveRecord::Base
end
class DistributionPluginSupplier < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode'
  belongs_to :consumer, :class_name => 'DistributionPluginNode'
end

class UseProfileIdInDistributionSuppliers < ActiveRecord::Migration

  def self.up
    remove_index "distribution_plugin_suppliers", :column => ["node_id", "consumer_id"]
    add_column :distribution_plugin_suppliers, :profile_id, :integer

    DistributionPluginSupplier.all.each do |supplier|
      supplier.profile_id = supplier.node.profile_id
      supplier.consumer_id = supplier.consumer.profile_id
      supplier.save(false)
    end

    remove_column :distribution_plugin_suppliers, :node_id
    add_index "distribution_plugin_suppliers", :column => ["profile_id", "consumer_id"]
  end

  def self.down
    say "this migration can't be reverted"
  end

end
