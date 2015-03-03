class OpenGraphPlugin::EnterpriseTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :enterprise

  self.static_trackers = true

  def self.trackers object_data, from_actor=nil
    profile = self.object_data_to_profile object_data
    trackers = profile.members.to_set
    trackers.merge profile.fans if profile.respond_to? :fans
    trackers.reject!{ |t| t == from_actor } if from_actor
    trackers.to_a
  end

end
