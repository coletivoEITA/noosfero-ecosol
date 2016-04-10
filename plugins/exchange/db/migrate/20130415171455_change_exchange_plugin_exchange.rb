class ChangeExchangePluginExchange < ActiveRecord::Migration
  def self.up
    remove_column :exchange_plugin_exchanges, :enterprise_target_id
    remove_column :exchange_plugin_exchanges, :enterprise_origin_id
  end

  def self.down
  end
end
