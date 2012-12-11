class AddQuantityAvailableToSessionProduct < ActiveRecord::Migration
  def self.up
    add_column :distribution_plugin_session_products, :quantity_available, :decimal
  end

  def self.down
    remove_column :distribution_plugin_session_products, :quantity_available
  end
end
