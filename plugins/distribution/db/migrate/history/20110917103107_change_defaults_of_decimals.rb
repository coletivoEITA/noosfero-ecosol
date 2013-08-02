class ChangeDefaultsOfDecimals < ActiveRecord::Migration
  def self.up
    change_column_default(:distribution_plugin_source_products, :quantity, 0)
    change_column_default(:distribution_plugin_sessions, :margin_fixed, 0)
    change_column_default(:distribution_plugin_products, :quantity, 0)
    change_column_default(:distribution_plugin_products, :stored, 0)
    change_column_default(:distribution_plugin_products, :minimum_selleable, 0)
    change_column_default(:distribution_plugin_products, :selleable_factor, 0)
    change_column_default(:distribution_plugin_ordered_products, :quantity_asked, 0)
    change_column_default(:distribution_plugin_ordered_products, :quantity_allocated, 0)
    change_column_default(:distribution_plugin_ordered_products, :quantity_payed, 0)
    change_column_default(:distribution_plugin_ordered_products, :price_asked, 0)
    change_column_default(:distribution_plugin_ordered_products, :price_allocated, 0)
    change_column_default(:distribution_plugin_ordered_products, :price_payed, 0)
  end

  def self.down
    say "this migration can't be reverted"
  end
end
