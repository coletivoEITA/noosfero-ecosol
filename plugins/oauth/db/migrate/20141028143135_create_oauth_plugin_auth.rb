class CreateOauthPluginAuth < ActiveRecord::Migration
  def up
    create_table :oauth_plugin_auths do |t|
      t.string :type
      t.integer :profile_id
      t.integer :client_id
      t.text :access_token
      t.datetime :expires_at
      t.text :data, default: {}.to_yaml

      t.timestamps
    end
    add_index :oauth_plugin_auths, [:profile_id]
    add_index :oauth_plugin_auths, [:client_id]
    add_index :oauth_plugin_auths, [:profile_id, :client_id], uniq: true
  end

  def down
    drop_table :oauth_plugin_auths
  end
end
