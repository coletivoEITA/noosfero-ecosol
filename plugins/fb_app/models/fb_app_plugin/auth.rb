class FbAppPlugin::Auth < OauthPlugin::ProviderAuth

  module Status
    Connected = 'connected'
    NotAuthorized = 'not_authorized'
    Unknown = 'unknown'
  end

  settings_items :signed_request
  settings_items :user
  attr_accessible :provider_user_id, :signed_request

  before_create :update_user
  before_create :exchange_token
  after_create :schedule_exchange_token
  after_destroy :destroy_page_tabs

  validates_presence_of :provider_user_id
  validates_uniqueness_of :provider_user_id, scope: :profile_id

  def self.parse_signed_request signed_request, credentials = FbAppPlugin.page_tab_app_credentials
    secret = credentials[:secret] rescue ''
    request = Facebook::SignedRequest.new signed_request, secret: secret
    request.data
  end

  def status
    if self.access_token.present? and self.not_expired? then Status::Connected else Status::NotAuthorized end
  end
  def not_authorized?
    self.status == Status::NotAuthorized
  end
  def connected?
    self.status == Status::Connected
  end

  def exchange_token
    app_id = FbAppPlugin.timeline_app_credentials[:id]
    app_secret = FbAppPlugin.timeline_app_credentials[:secret]
    fb_auth = FbGraph::Auth.new app_id, app_secret
    fb_auth.exchange_token! self.access_token
    self.expires_in = fb_auth.access_token.expires_in
    self.access_token = fb_auth.access_token.access_token
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

  def destroy_page_tabs
    self.profile.fb_app_page_tabs.destroy_all
  end

  def schedule_exchange_token
    self.exchange_token
    self.save!
    # repeat this again
    self.schedule_exchange_token
  end
  handle_asynchronously :schedule_exchange_token, run_at: proc{ 1.month.from_now }

end

