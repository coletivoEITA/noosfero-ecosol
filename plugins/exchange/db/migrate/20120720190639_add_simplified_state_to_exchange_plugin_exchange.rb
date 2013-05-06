class AddSimplifiedStateToExchangePluginExchange < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchanges, :simplified_state, :string
  end

  def self.down
    remove_column :exchange_plugin_exchanges, :simplified_state
  end
end
