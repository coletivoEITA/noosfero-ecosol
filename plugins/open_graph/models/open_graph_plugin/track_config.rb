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

  scope :profile_trackers, lambda { |profile, exclude_actor=nil|
    scope = where object_data_id: profile.id, object_data_type: profile['type']
    scope = scope.where ['actor_id <> ?', exclude_actor.id] if exclude_actor
    scope
  }

  def self.enabled_for context, actor, object_type = nil
    settings = actor.send "#{context}_settings"
    settings.send "#{self.track_name}_track_enabled"
  end

  # redefine on subclasses
  def self.trackers object_data, from_actor
    return [] unless object_data.is_a? Profile
    self.profile_trackers object_data, from_actor
  end

end
