require_dependency 'profile'

class Profile

  def network?
    self.class == NetworksPlugin::Network
  end

end
