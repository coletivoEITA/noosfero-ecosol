require_dependency 'enterprise'

class Enterprise

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories

end
