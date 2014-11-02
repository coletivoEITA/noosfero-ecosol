class CreateOpenGraphPublishConfig < ActiveRecord::Migration
  def up
    create_table :open_graph_plugin_publish_configs do |t|
      t.string :type
      t.integer :profile_id
      t.text :config, :default => {}.to_yaml
    end

    add_index :open_graph_plugin_publish_configs, [:type]
    add_index :open_graph_plugin_publish_configs, [:profile_id]
    add_index :open_graph_plugin_publish_configs, [:type, :profile_id]
  end

  def down
    drop_table :open_graph_plugin_publish_configs
  end
end
