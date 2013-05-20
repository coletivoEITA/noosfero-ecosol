class AddExchangePluginExchangeEnterprise < ActiveRecord::Migration
  def self.up
    create_table :exchange_plugin_exchange_enterprises do |t|
      t.integer :enterprise_id
      t.integer :exchange_id
      t.time_stamps
    end
  end

  def self.down
    drop_table :exchange_plugin_exchanges_enterprises
  end
end
