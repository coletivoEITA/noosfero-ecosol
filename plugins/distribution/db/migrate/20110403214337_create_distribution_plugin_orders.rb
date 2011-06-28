class CreateDistributionPluginOrders < ActiveRecord::Migration
  def self.up
    create_table :distribution_plugin_orders do |t|
      t.integer :session_id
      t.integer :consumer_id
      t.integer :supplier_delivery_id
      t.integer :consumer_delivery_id
      t.decimal :total_collected
      t.decimal :total_payed
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_plugin_orders
  end
end
