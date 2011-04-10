class CreateDistributionProducts < ActiveRecord::Migration
  def self.up
    create_table :distribution_products do |t|
      t.integer :product_id
      t.integer :node_id
      t.boolean :active
      t.decimal :price
      t.integer :unit_id
      t.decimal :quantity
      t.decimal :stored
      t.decimal :minimum_selleable
      t.decimal :selleable_factor

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_products
  end
end
