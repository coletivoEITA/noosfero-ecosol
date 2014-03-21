class FbAppEcosolStorePlugin::SignedRequestConfig < Noosfero::Plugin::ActiveRecord

  serialize :config, Hash

  validates_presence_of :signed_request

  def profiles
    self.config ||= {}
    Profile.where(:id => self.config[:data]) if self.config[:type] = 'profiles'
  end

  def profiles= profiles
    self.config[:type] = 'profiles'
    self.config[:data] = profiles.map(&:id)
  end

  def profile_ids= profile_ids
    if profile_ids.is_a?(Array) and profile_ids.length > 0
      profile_ids.map{|elm| elm.to_i}
      self.profiles = Profile.where('id in (?)',profile_ids)
    else
      self.profiles = []
    end
  end

  def query
    self.config ||= {}
    self.config[:data] if self.config[:type] = 'query'
  end

  def query= value
    self.config[:type] = 'query'
    self.config[:data] = value if self.config[:type] = 'query'
  end

end
