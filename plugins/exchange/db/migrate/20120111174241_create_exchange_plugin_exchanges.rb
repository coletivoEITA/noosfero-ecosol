class CreateExchangePluginExchanges < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_exchanges do |t|
      t.string :slug
      t.string :state
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :exchange_plugin_exchanges
  end
end
