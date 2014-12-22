require_dependency 'article'

class Article

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories

end
