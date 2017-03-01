class CreateCurrencyPluginCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currency_plugin_currencies do |t|
      t.integer :environment_id
      t.string :symbol
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :currency_plugin_currencies
  end
end

