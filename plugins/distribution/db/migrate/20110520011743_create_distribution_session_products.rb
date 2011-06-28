class CreateDistributionSessionProducts < ActiveRecord::Migration
  def self.up
    create_table :distribution_session_products do |t|
      t.integer :order_session_id
      t.integer :product_id
      t.decimal :price
      t.boolean :limited_by_stock

      t.timestamps
    end
  end

  def self.down
    drop_table :distribution_session_products
  end
end
