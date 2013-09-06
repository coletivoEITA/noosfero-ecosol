require_dependency 'profile'

class Profile

  # not dependent to keep history
  has_one :distribution_node, :foreign_key => :profile_id, :class_name => 'DistributionPlugin::Node'

  def distribution_enabled?
    node ||= DistributionPlugin::Node.find_or_create self
    node.enabled?
  end

end
