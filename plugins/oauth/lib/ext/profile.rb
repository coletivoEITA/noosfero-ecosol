require_dependency 'profile'

class Profile

  has_many :oauth_auths, class_name: 'OauthPlugin::Auth'

end
