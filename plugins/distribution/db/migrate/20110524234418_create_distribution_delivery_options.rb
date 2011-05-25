class CreateDistributionDeliveryOptions < ActiveRecord::Migration
  def self.up
    create_table :distribution_delivery_options do |t|
      t.integer :order_session_id
      t.integer :delivery_method_id

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_delivery_options
  end
end
