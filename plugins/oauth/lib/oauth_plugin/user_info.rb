class OauthPlugin::UserInfo

  attr_reader :auth
  attr_reader :provider

  def initialize provider, auth
    @auth = auth
    @provider = provider
  end

  def signup_params
    self.send "from_#{provider}_auth"
  end

  protected

  def from_noosfero_auth
    {
      :user => {
        :email => self.auth.info.email,
        :login => self.auth.info.identifier,
      },
      :profile_data => {
        :name => self.auth.info.name,
      },
    }
  end

  def from_persona_auth
    {
      :user => {
        :email => self.auth.info.email,
      },
      :profile_data => {
        :name => self.auth.info.name,
      },
    }
  end

  def from_twitter_auth
    {
      :user => {
        :login => self.auth.info.nickname,
      },
      :profile_data => {
        :name => self.auth.info.name,
      },
    }
  end

  def from_google_oauth2_auth
    {
      :user => {
        :email => self.auth.info.email,
        :login => self.auth.info.id,
      },
      :profile_data => {
        :name => self.auth.info.name,
      },
    }
  end

  def from_facebook_auth
    {
      :user => {
        :email => self.auth.info.email,
        :login => self.auth.info.nickname,
      },
      :profile_data => {
        :name => self.auth.info.name,
      },
    }
  end

end
