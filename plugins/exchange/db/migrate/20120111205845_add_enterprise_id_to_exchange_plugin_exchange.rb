class AddEnterpriseIdToExchangePluginExchange < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchanges, :enterprise_target_id, :integer
    add_column :exchange_plugin_exchanges, :enterprise_origin_id, :integer
  end

  def self.down
    remove_column :exchange_plugin_exchanges, :enterprise_origin_id
    remove_column :exchange_plugin_exchanges, :enterprise_target_id
  end
end
