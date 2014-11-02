class CreateOauthPluginProviderAuth < ActiveRecord::Migration
  def up
    create_table :oauth_plugin_provider_auths do |t|
      t.string :type
      t.integer :profile_id
      t.integer :provider_id
      t.string :provider_user_id
      t.text :access_token
      t.datetime :expires_at
      t.text :scope
      t.text :data, default: {}.to_yaml

      t.timestamps
    end
    add_index :oauth_plugin_provider_auths, [:profile_id]
    add_index :oauth_plugin_provider_auths, [:provider_id]
    add_index :oauth_plugin_provider_auths, [:provider_user_id]
    add_index :oauth_plugin_provider_auths, [:profile_id, :provider_user_id], name: 'oauth_index_profile_id_and_provider_user_id'
    add_index :oauth_plugin_provider_auths, [:profile_id, :provider_id], uniq: true
  end

  def down
    drop_table :oauth_plugin_provider_auths
  end
end
