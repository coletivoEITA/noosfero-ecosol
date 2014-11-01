class FbAppPlugin::Auth < OauthPlugin::ProviderAuth

  settings_items :signed_request
  settings_items :user_id
  settings_items :user
  attr_accessible :user_id, :signed_request

  before_create :update_user

  def self.parse_signed_request signed_request
    secret = FbAppPlugin.config['app']['secret'] rescue ''
    request = Facebook::SignedRequest.new signed_request, secret: secret
    request.data
  end

  def signed_request_data
    self.class.parse_signed_request self.signed_request
  end

  def fetch_user
    @user ||= begin
      user = FbGraph::User.me self.access_token
      self.user = user.fetch
    end
  end
  def update_user
    self.user = self.fetch_user
  end

  protected

end

