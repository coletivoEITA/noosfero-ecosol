OauthPlugin::Client = Songkick::OAuth2::Model::Client

class OauthPlugin::Client
  attr_accessible :client_id, :client_secret
  attr_accessible :oauth2_client_owner_id, :oauth2_client_owner_type
end

