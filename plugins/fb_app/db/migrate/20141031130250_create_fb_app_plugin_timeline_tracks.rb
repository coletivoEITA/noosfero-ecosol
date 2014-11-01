class CreateFbAppPluginTimelineTracks < ActiveRecord::Migration
  def up
    create_table :fb_app_plugin_timeline_tracks do |t|
      t.integer :profile_id
      t.integer :object_owner_id
      t.string :object_owner_type

      t.timestamps
    end
  end

  def down
    drop_table :fb_app_plugin_timeline_tracks
  end
end
