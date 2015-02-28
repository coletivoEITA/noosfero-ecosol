class OpenGraphPlugin::TrackConfig < OpenGraphPlugin::Track

  Types = {
    activity: 'ActivityTrackConfig',
    enterprise: 'EnterpriseTrackConfig',
    community: 'CommunityTrackConfig',
    #friend: 'FriendTrackConfig',
  }

  class_attribute :track_name
  def self.track_enabled_field
    "#{self.track_name}_track_enabled"
  end

end
