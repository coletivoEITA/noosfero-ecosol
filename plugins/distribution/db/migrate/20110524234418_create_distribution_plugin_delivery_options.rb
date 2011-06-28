class CreateDistributionPluginDeliveryOptions < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_delivery_options do |t|
      t.integer :session_id
      t.integer :delivery_method_id

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_plugin_delivery_options
  end
end
