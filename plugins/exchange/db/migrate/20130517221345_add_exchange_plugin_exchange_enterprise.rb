class AddExchangePluginExchangeEnterprise < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_exchange_enterprises do |t|
      t.integer :enterprise_id
      t.integer :exchange_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :exchange_plugin_exchanges_enterprises
  end
end
