class OpenGraphPlugin::TrackConfig < OpenGraphPlugin::Track

  Types = {
    activity: 'ActivityTrackConfig',
    enterprise: 'EnterpriseTrackConfig',
    community: 'CommunityTrackConfig',
    # TODO: not yet implemented
    #friend: 'FriendTrackConfig',
  }

  # define on subclasses (required)
  class_attribute :track_name
  def self.track_enabled_field
    "#{self.track_name}_track_enabled"
  end

  # true if do not depend on records (e.g. EnterpriseTrackConfig depends on friends)
  # redefine on subclasses
  class_attribute :static_trackers
  self.static_trackers = false

  scope :profile_trackers, lambda { |profile, exclude_actor=nil|
    scope = where object_data_id: profile.id, object_data_type: profile.class.base_class
    scope = scope.where context: OpenGraphPlugin.context
    scope = scope.includes :tracker
    scope = scope.where ['tracker_id <> ?', exclude_actor.id] if exclude_actor
    scope
  }

  def self.enabled_for context, actor
    settings = actor.send "#{context}_settings"
    settings.send "#{self.track_name}_track_enabled"
  end

  def self.object_data_to_profile object_data
    case object_data
    when Profile
      profile = object_data
    else
      profile = object_data.profile
    end
  end

  # redefine on subclasses
  def self.trackers object_data, from_actor=nil
    profile = self.object_data_to_profile object_data
    tracks = self.profile_trackers(profile, from_actor).where(type: self)
    tracks.map(&:tracker)
  end

end
