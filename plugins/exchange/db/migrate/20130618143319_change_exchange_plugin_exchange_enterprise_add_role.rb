class ChangeExchangePluginExchangeEnterpriseAddRole < ActiveRecord::Migration
  def self.up
    add_column :exchange_plugin_exchange_enterprises, :role, :string
  end

  def self.down
    remove_column :exchange_plugin_exchange_enterprises, :role
  end
end
