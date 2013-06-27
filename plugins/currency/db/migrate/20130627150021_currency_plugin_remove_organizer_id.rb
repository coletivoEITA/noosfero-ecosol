class CurrencyPluginRemoveOrganizerId < ActiveRecord::Migration

  def self.up
    remove_column :currency_plugin_currencies, :organizer_id
  end

  def self.down
    say "this migration can't be reverted"
  end

end
