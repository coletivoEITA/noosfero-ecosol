class CreateOauthPluginProviders < ActiveRecord::Migration
  def self.up
    create_table :oauth_plugin_providers do |t|
      t.integer :environment_id
      t.string :type
      t.string :strategy
      t.string :identifier
      t.string :name
      t.string :site
      t.integer :image_id
      t.string :key
      t.string :secret
      t.text :scope

      t.timestamps
    end

    add_index :oauth_plugin_providers, :environment_id
    add_index :oauth_plugin_providers, :type
    add_index :oauth_plugin_providers, :strategy
    add_index :oauth_plugin_providers, :identifier
    add_index :oauth_plugin_providers, [:environment_id, :identifier]
  end

  def self.down
    drop_table :oauth_plugin_providers
  end
end
