require_dependency 'environment'
require 'songkick/oauth2/provider'

class Environment

  has_many :oauth_providers, :class_name => 'OauthPlugin::Provider'

  has_many :oauth_apps, :class_name => '::Songkick::OAuth2::Model::Client', :as => :oauth2_client_owner
  include ::Songkick::OAuth2::Model::ClientOwner

end
