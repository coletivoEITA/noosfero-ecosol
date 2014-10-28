class CreateOauthPluginUserAccesses < ActiveRecord::Migration
  def up
    create_table :oauth_plugin_user_accesses do |t|
      t.integer :profile_id
      t.integer :client_id
      t.text :access_token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :oauth_plugin_user_accesses, [:profile_id]
    add_index :oauth_plugin_user_accesses, [:client_id]
    add_index :oauth_plugin_user_accesses, [:profile_id, :client_id], uniq: true
  end

  def down
    drop_table :oauth_plugin_user_accesses
  end
end
