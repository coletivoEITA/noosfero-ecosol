class NetworksPlugin::BaseNode < Organization

  self.abstract_class = true

  delegate :parent, :to => :network_node_child_relation, :allow_nil => true
  def parent= node
    self.network_node_child_relations = []
    self.network_node_child_relations.build :parent => node, :child => self
  end

  # FIXME: use acts_as_filesystem
  def hierarchy
    @hierarchy = []
    item = self
    while item
      @hierarchy.unshift(item)
      item = item.parent
    end
    @hierarchy
  end

  def nodes
    self.network_node_parent_relations.all(:conditions => {:child_type => 'NetworksPlugin::Node'}).collect &:child
  end

  def node?
    false
  end
  def network?
    false
  end

  protected

  def default_template
    return if self.is_template
    self.environment.network_template
  end

end
