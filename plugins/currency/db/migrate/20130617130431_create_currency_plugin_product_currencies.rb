class CreateCurrencyPluginProductCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currency_plugin_product_currencies do |t|
      t.integer :product_id
      t.integer :currency_id
      t.float :price
      t.float :discount

      t.timestamps
    end
  end

  def self.down
    drop_table :currency_plugin_product_currencies
  end
end
