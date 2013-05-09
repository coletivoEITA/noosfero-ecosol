require_dependency 'profile'

class Profile

  has_one :sniffer_profile, :class_name => 'SnifferPluginProfile'

  def distance 
    @distance
  end
  def distance=(value)
    @distance = value
  end

end
