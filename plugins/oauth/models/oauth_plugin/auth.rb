#OauthPlugin::Auth = Songkick::OAuth2::Model::Authorization

class OauthPlugin::Auth < ActiveRecord::Base

  attr_accessible :profile_id, :client_id
  attr_accessible :access_token, :expires_in, :expires_at

  belongs_to :profile
  belongs_to :client, class_name: '::OauthPlugin::Client'

  validates_presence_of :profile
  validates_presence_of :client
  validates_uniqueness_of :client_id, scope: :profile_id
  validates_presence_of :access_token

  acts_as_having_settings field: :data

  def expires_in
    Time.now - self.expires_at
  end
  def expires_in= value
    self.expires_at = Time.now + value.to_i
  end

end
