class AddExchangeIdToExchangePluginExchangeElement < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchange_elements, :exchange_id, :integer
  end

  def self.down
    remove_column :exchange_plugin_exchange_elements, :exchange_id
  end
end
