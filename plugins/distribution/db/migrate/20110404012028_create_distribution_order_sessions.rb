class CreateDistributionOrderSessions < ActiveRecord::Migration
  def self.up
    create_table :distribution_order_sessions do |t|
      t.integer :node_id
      t.datetime :start
      t.datetime :finish

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_order_sessions
  end
end
