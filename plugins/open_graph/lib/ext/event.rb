require_dependency 'event'

class Event

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories

end
