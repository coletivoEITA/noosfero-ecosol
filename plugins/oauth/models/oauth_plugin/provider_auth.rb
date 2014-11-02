
class OauthPlugin::ProviderAuth < ActiveRecord::Base

  attr_accessible :profile_id, :provider_id
  attr_accessible :access_token, :expires_in, :expires_at

  belongs_to :profile
  belongs_to :provider, class_name: '::OauthPlugin::Provider'

  validates_presence_of :profile
  validates_presence_of :provider
  validates_uniqueness_of :profile_id, scope: :provider_id
  validates_presence_of :access_token

  acts_as_having_settings field: :data

  def expires_in
    self.expires_at - Time.now
  end
  def expires_in= value
    self.expires_at = Time.now + value.to_i
  end

  def not_expired?
    Time.now <= self.expires_at rescue false
  end
  def expired?
    not self.not_expired?
  end

end
