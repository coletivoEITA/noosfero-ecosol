class OpenGraphPlugin::CommunityTrack < OpenGraphPlugin::Track

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

end
