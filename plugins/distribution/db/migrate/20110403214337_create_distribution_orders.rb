class CreateDistributionOrders < ActiveRecord::Migration
  def self.up
    create_table :distribution_orders do |t|
      t.integer :order_session_id
      t.integer :consumer_id
      t.integer :supplier_delivery_id
      t.integer :consumer_delivery_id
      t.decimal :total_collected
      t.decimal :total_payed

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_orders
  end
end
