class CreateDistributionDeliveryMethods < ActiveRecord::Migration
  def self.up
    create_table :distribution_delivery_methods do |t|
      t.integer :node_id
      t.string  :name
      t.text    :description
      t.string  :recipient
      t.string  :address_line1
      t.string  :address_line2
      t.string  :postal_code
      t.string  :state
      t.string  :country

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_delivery_methods
  end
end
