class OpenGraphPlugin::ActivityTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :activity

  def self.objects
    [
      'blog_post',
      'friendship',
      'gallery_image',
      'uploaded_file',
      'product',
      'forum',
      'event',
      'enterprise',
    ]
  end

  validates_inclusion_of :object_type, in: self.objects

  protected

end

