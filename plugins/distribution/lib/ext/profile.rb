require_dependency 'profile'

class Profile
  # not dependent to keep history
  has_one :node, :foreign_key => 'profile_id', :class_name => 'DistributionPluginNode'
end
