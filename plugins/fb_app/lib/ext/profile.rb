require_dependency 'profile'

class Profile

  def fb_app_auth
    #client = FbAppPlugin.oauth_provider_for self.environment
    client = OauthPlugin::Provider.find 7
    self.oauth_auths.where(client_id: client.id).first
  end

end
