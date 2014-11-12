class OpenGraphPlugin::Track < ActiveRecord::Base

  Config = {
    activity: 'ActivityTrack',
    enterprise: 'EnterpriseTrack',
    friend: 'FriendTrack',
    community: 'CommunityTrack',
  }

  def self.objects
    []
  end

  attr_accessible :type, :scope, :tracker_id, :tracker,
    :object_type, :object_data, :object_data_id, :object_data_type, :object_data_url

  belongs_to :tracker, class_name: 'Profile'
  belongs_to :actor, class_name: 'Profile'
  belongs_to :object_data, polymorphic: true

end
