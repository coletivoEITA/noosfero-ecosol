class CreateDistributionPluginSuppliers < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_suppliers do |t|
      t.integer :node_id
      t.integer :consumer_id
      t.string :name
      t.string :name_abbreviation
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_plugin_suppliers
  end
end
