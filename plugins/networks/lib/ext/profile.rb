require_dependency 'profile'

class Profile

  def network?
    self.class == NetworksPlugin::Network
  end
  def network_node?
    self.class == NetworksPlugin::Node
  end

end
