class CreateFbAppEcosolStoreRequestConfig < ActiveRecord::Migration
  def self.up
    create_table :fb_app_ecosol_store_plugin_signed_request_configs do |t|
      t.text :signed_request
      t.text :config

      t.timestamps
    end
    add_index :fb_app_ecosol_store_plugin_signed_request_configs, :signed_request
  end

  def self.down
    drop_table :fb_app_ecosol_store_signed_request_configs
    #drop_table :fb_app_ecosol_store_signed_plugin_request_configs
  end
end
