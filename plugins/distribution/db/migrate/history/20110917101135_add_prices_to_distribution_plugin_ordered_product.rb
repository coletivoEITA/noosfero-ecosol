class AddPricesToDistributionPluginOrderedProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_ordered_products, :price_asked, :decimal
    add_column :distribution_plugin_ordered_products, :price_allocated, :decimal
    add_column :distribution_plugin_ordered_products, :price_payed, :decimal
  end

  def self.down
    remove_column :distribution_plugin_ordered_products, :price_payed
    remove_column :distribution_plugin_ordered_products, :price_allocated
    remove_column :distribution_plugin_ordered_products, :price_asked
  end
end
