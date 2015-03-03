class OpenGraphPlugin::EnterpriseTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :enterprise

  self.static_trackers = true

  def self.trackers_of_profile enterprise
    trackers = enterprise.members.to_set
    trackers.merge enterprise.fans if enterprise.respond_to? :fans
    #trackers.reject!{ |t| t == from_actor } if from_actor
    trackers.to_a
  end

end
