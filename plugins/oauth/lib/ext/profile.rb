require_dependency 'profile'

class Profile

  has_many :oauth_provider_auths, class_name: 'OauthPlugin::ProviderAuth'
  has_many :oauth_client_auths, class_name: 'OauthPlugin::ClientAuth', as: :oauth2_resource_owner

end
