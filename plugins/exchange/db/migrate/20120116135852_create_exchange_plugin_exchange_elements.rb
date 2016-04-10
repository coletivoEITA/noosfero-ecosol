class CreateExchangePluginExchangeElements < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_exchange_elements do |t|
      t.integer :element_id
      t.string :element_type
      t.decimal :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :exchange_plugin_exchange_elements
  end
end
