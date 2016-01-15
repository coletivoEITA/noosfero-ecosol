class AddEnterpriseIdToExchangePluginExchangeElement < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchange_elements, :enterprise_id, :integer
  end

  def self.down
    remove_column :exchange_plugin_exchange_elements, :enterprise_id
  end
end
