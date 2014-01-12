class RefactorOrdersPluginOrderedProduct < ActiveRecord::Migration
  def self.up
    remove_column :orders_plugin_orders, :total_collected
    remove_column :orders_plugin_orders, :total_payed

    rename_table :orders_plugin_products, :orders_plugin_items

    rename_column :orders_plugin_items, :quantity_allocated, :quantity_accepted
    rename_column :orders_plugin_items, :quantity_payed, :quantity_shipped
    rename_column :orders_plugin_items, :price_allocated, :price_accepted
    rename_column :orders_plugin_items, :price_payed, :price_shipped

    add_column :orders_plugin_items, :name, :string
    add_column :orders_plugin_items, :price, :decimal
  end

  def self.down
    say "this migration can't be reverted"
  end
end
