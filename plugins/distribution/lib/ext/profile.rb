class Profile
  has_one :node, :foreign_key => 'profile_id', :class_name => 'DistributionPluginNode', :dependent => :destroy
end
