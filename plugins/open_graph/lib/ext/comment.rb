require_dependency 'comment'

class Comment

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories

end
