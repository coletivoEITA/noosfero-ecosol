require_dependency 'profile'

class Profile < ActiveRecord::Base
  # not dependent to keep history
  has_one :node, :foreign_key => 'profile_id', :class_name => 'DistributionPluginNode'
end
