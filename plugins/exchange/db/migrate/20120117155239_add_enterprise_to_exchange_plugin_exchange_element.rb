class AddEnterpriseToExchangePluginExchangeElement < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchange_elements, :enterprise, :string
  end

  def self.down
    remove_column :exchange_plugin_exchange_elements, :enterprise
  end
end
