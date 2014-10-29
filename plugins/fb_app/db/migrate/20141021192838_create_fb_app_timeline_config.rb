class CreateFbAppTimelineConfig < ActiveRecord::Migration
  def up
    create_table :fb_app_plugin_timeline_configs do |t|
      t.integer :profile_id
      t.text :config, :default => {}.to_yaml
    end

    add_index :fb_app_plugin_timeline_configs, :profile_id

    rename_table :fb_app_ecosol_store_plugin_page_configs, :fb_app_plugin_page_tab_configs
    add_column :fb_app_plugin_page_tab_configs, :profile_id, :integer
    add_index :fb_app_plugin_page_tab_configs, [:profile_id]
  end

  def down
    drop_table :fb_app_plugin_timeline_configs
  end
end
