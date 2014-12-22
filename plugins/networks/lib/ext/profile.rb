require_dependency 'profile'

class Profile

  def node?
    self.is_a? NetworksPlugin::BaseNode
  end
  def network?
    self.class == NetworksPlugin::Network
  end
  def network_node?
    self.class == NetworksPlugin::Node
  end

end
