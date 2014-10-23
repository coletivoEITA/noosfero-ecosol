class CreateFbAppRequestConfig < ActiveRecord::Migration
  def self.up
    create_table :fb_app_ecosol_store_plugin_page_configs do |t|
      t.string :page_id
      t.text :config, :default => {}.to_yaml

      t.timestamps
    end
    add_index :fb_app_ecosol_store_plugin_page_configs, :page_id
  end

  def self.down
    drop_table :fb_app_ecosol_store_plugin_page_configs
  end
end
