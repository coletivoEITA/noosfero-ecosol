class CreateDistributionOrders < ActiveRecord::Migration
  def self.up
    create_table :distribution_orders do |t|
      t.integer :order_session_id
      t.integer :delivery_method
      t.integer :buyer

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_orders
  end
end
