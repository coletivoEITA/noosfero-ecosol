class CreateStockPluginPlaces < ActiveRecord::Migration
  def self.up
    create_table :stock_plugin_places do |t|
      t.integer :profile_id
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :stock_plugin_places, :profile_id
  end

  def self.down
    drop_table :stock_plugin_places
  end
end
