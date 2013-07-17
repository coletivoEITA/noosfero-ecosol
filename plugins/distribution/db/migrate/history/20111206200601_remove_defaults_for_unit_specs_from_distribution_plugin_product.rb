class RemoveDefaultsForUnitSpecsFromDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    change_column_default :distribution_plugin_products, :minimum_selleable, nil
    change_column_default :distribution_plugin_products, :unit_detail, nil
  end

  def self.down
    say "this migration can't be reverted"
  end
end
