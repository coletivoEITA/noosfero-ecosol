class FbAppEcosolStorePlugin::SignedRequestConfig < Noosfero::Plugin::ActiveRecord

  serialize :config, Hash

  validates_presence_of :signed_request

  def profiles
    self.config ||= {}
    Profile.where(:id => self.config[:data]) if self.config[:type] = 'profiles'
  end

  def profiles= value

  end

end
