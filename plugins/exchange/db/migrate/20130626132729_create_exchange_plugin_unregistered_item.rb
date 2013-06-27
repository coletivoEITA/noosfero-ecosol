class CreateExchangePluginUnregisteredItem < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_unregistered_items do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :exchange_plugin_unregistered_items
  end
end

