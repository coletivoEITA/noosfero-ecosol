require_dependency 'environment'

class Environment

  has_many :networks, :class_name => 'NetworksPlugin::Network'

end
