class OpenGraphPlugin::EnterpriseTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :enterprise

end
