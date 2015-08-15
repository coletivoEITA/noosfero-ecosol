# this move from the legacy oauth plugin auth data to oauth_client plugin
#
class OauthPluginProviderAuth < ActiveRecord::Base

end
class FbAppPlugin::Auth < OauthClientPlugin::Auth
  attr_accessible *self.column_names
end

class MoveFbAppPluginAuthToOauthClientPlugin < ActiveRecord::Migration

  def up
    return unless ActiveRecord::Base.connection.table_exists? :oauth_plugin_provider_auths

    OauthPluginProviderAuth.find_each batch_size: 50 do |auth|
      attrs = auth.attributes

      profile = Profile.find attrs['profile_id'] rescue nil
      next puts "can't find profile for auth #{attrs.inspect}" if profile.blank?
      attrs.delete 'provider_id'
      provider = FbAppPlugin.oauth_provider_for profile.environment
      attrs['provider'] = provider

      attrs['data'][:fb_user] = attrs['data'].delete :user
      attrs['enabled'] = true
      FbAppPlugin::Auth.create! attrs
    end
  end

  def down
    say "this migration can't be reverted"
  end

end
