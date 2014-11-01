class CreateFbAppPluginActivities < ActiveRecord::Migration
  def up
    create_table :fb_app_plugin_activities do |t|
      t.integer :actor_id
      t.integer :action
      t.integer :object
      t.integer :object_url

      t.timestamps
    end
  end

  def down
    drop_table :fb_app_plugin_activities
  end
end
