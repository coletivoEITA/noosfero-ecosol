require_dependency 'profile'

class Profile

  has_many :open_graph_activities, class_name: 'OpenGraphPlugin::Activity', source: :tracker_id

  has_many :open_graph_tracks, class_name: 'OpenGraphPlugin::Track', source: :tracker_id

  OpenGraphPlugin::Track::Config.keys.each do |track, klass|
    has_many "open_graph_#{track}_tracks", class_name: "OpenGraphPlugin::#{klass}", source: :tracker_id
    attr_accessible "open_graph_#{track}_tracks_attributes"
    accepts_nested_attributes_for "open_graph_#{track}_tracks", allow_destroy: true
  end

end
