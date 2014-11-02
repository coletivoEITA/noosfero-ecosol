require_dependency 'product'

class Product

  extend OpenGraphPlugin::AttachStories::ClassMethods
  open_graph_attach_stories

end
