class CreateDistributionPluginNodes < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_nodes do |t|
      t.integer :profile_id
      t.string  :role
      t.text    :features

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_plugin_nodes
  end
end
