require_dependency 'friendship'

class Friendship

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories

end
