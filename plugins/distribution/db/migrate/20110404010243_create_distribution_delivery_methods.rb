class CreateDistributionDeliveryMethods < ActiveRecord::Migration
  def self.up
    create_table :distribution_delivery_methods do |t|
      t.integer :node_id
      t.integer :address_id

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_delivery_methods
  end
end
