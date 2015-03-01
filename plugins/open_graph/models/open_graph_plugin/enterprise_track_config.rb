class OpenGraphPlugin::EnterpriseTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :enterprise

  def self.trackers object_data, from_actor
    case object_data
    when Product
      profile = object_data.profile
    when Profile
      profile = object_data
    end
    trackers = profile.members.to_set
    trackers.concat profile.fans if profile.respond_to? :fans
    trackers.reject!{ |t| t == from_actor }
    trackers
  end

end
