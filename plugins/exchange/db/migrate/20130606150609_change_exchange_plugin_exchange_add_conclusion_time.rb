class ChangeExchangePluginExchangeAddConclusionTime < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchanges, :concluded_at, :datetime
  end

  def self.down
    remove_column :exchange_plugin_exchanges, :concluded_at
  end
end
