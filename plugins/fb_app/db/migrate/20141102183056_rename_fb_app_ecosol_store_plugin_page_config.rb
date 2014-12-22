class RenameFbAppEcosolStorePluginPageConfig < ActiveRecord::Migration

  def up
    rename_table :fb_app_ecosol_store_plugin_page_configs, :fb_app_plugin_page_tab_configs
    add_column :fb_app_plugin_page_tab_configs, :profile_id, :integer
    add_index :fb_app_plugin_page_tab_configs, [:profile_id]
  end

  def down
  end

end
