require_dependency 'user'

class User

  include Songkick::OAuth2::Model::ResourceOwner

end
