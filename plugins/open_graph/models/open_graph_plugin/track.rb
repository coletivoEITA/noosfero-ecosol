class OpenGraphPlugin::Track < ActiveRecord::Base

  Config = {
    activity: 'ActivityTrack',
    enterprise: 'EnterpriseTrack',
    friend: 'FriendTrack',
    community: 'CommunityTrack',
  }

  scope :profile_trackers, lambda { |profile, exclude_actor=nil|
    scope = where object_data_id: profile.id, object_data_type: profile['type']
    scope = scope.where ['actor_id <> ?', exclude_actor.id] if exclude_actor
    scope
  }

  def self.objects
    []
  end

  attr_accessible :type, :scope, :tracker_id, :tracker, :actor_id, :action,
    :object_type, :object_data, :object_data_id, :object_data_type, :object_data_url

  belongs_to :tracker, class_name: 'Profile'
  belongs_to :actor, class_name: 'Profile'
  belongs_to :object_data, polymorphic: true

end

