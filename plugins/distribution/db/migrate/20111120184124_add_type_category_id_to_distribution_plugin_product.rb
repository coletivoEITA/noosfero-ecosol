class AddTypeCategoryIdToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_products, :type_category_id, :integer
  end

  def self.down
    remove_column :distribution_plugin_products, :type_category_id
  end
end
