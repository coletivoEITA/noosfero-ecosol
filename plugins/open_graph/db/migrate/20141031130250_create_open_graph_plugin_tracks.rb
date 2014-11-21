class CreateOpenGraphPluginTracks < ActiveRecord::Migration
  def up
    create_table :open_graph_plugin_tracks do |t|
      t.string :type
      t.string :scope

      t.integer :tracker_id

      t.integer :actor_id

      t.string :action

      t.string :object_type
      t.text :object_data_url
      t.integer :object_data_id
      t.string :object_data_type

      t.boolean :enabled, default: true

      t.timestamps
    end

    add_index :open_graph_plugin_tracks, [:type]
    add_index :open_graph_plugin_tracks, [:scope]
    add_index :open_graph_plugin_tracks, [:type, :scope]
    add_index :open_graph_plugin_tracks, [:actor_id]
    add_index :open_graph_plugin_tracks, [:action]
    add_index :open_graph_plugin_tracks, [:object_type]
    add_index :open_graph_plugin_tracks, [:enabled]
    add_index :open_graph_plugin_tracks, [:object_data_url]
    add_index :open_graph_plugin_tracks, [:object_data_id, :object_data_type], name: 'index_open_graph_plugin_tracks_object_data_id_type'
  end

  def down
    drop_table :open_graph_plugin_tracks
  end
end
