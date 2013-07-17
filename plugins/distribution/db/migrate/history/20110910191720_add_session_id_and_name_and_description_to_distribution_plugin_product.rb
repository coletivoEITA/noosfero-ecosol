class AddSessionIdAndNameAndDescriptionToDistributionPluginProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_products, :session_id, :integer
    add_column :distribution_plugin_products, :name, :string
    add_column :distribution_plugin_products, :description, :text
    drop_table :distribution_plugin_session_products
  end

  def self.down
    say 'this migration can\'t be reverted'
  end
end
