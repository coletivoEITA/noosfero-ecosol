class ClearDefaultsOfStoredAndQuantity < ActiveRecord::Migration
  def self.up
    change_column_default(:distribution_plugin_products, :stored, nil)
    change_column_default(:distribution_plugin_products, :quantity, nil)
  end

  def self.down
    say "this migration can't be reverted"
  end
end
