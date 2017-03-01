class AddDescriptionToStockPluginAllocations < ActiveRecord::Migration
  def change
    add_column :stock_plugin_allocations, :description, :text
  end
end
