class RenameCurrencyEnterprise < ActiveRecord::Migration
  def self.up
    rename_table :currency_plugin_currency_enterprises, :currency_plugin_enterprise_currencies
  end

  def self.down
    say "this migration can't be reverted"
  end
end
