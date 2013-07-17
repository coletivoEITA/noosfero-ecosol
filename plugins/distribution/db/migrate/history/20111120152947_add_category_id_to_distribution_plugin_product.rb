class AddCategoryIdToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_products, :category_id, :integer
  end

  def self.down
    remove_column :distribution_plugin_products, :category_id
  end
end
