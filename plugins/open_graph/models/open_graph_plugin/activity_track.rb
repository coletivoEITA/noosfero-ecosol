class OpenGraphPlugin::ActivityTrack < OpenGraphPlugin::Track

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  def self.objects
    [
      'blog_post',
      'friendship',
      'gallery_image',
      'uploaded_file',
    ]
  end

  validates_inclusion_of :object_type, in: self.objects

end

