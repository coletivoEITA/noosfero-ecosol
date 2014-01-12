require_dependency 'profile'

class Profile

  has_many :network_node_child_relations, :foreign_key => :child_id, :class_name => 'SubOrganizationsPlugin::Relation', :dependent => :destroy, :include => [:parent],
    :conditions => ["parent_type = 'NetworksPlugin::Node' OR parent_type = 'NetworksPlugin::Network'"]
  has_many :network_node_parent_relations, :foreign_key => :parent_id, :class_name => 'SubOrganizationsPlugin::Relation', :include => [:child],
    :conditions => ["child_type = 'NetworksPlugin::Node' OR child_type = 'NetworksPlugin::Network'"]
  def network_node_child_relation
    self.network_node_child_relations.first
  end

  def networks_settings
    @networks_settings ||= Noosfero::Plugin::Settings.new self, NetworksPlugin
  end

  def node?
    self.is_a? NetworksPlugin::BaseNode
  end
  def network?
    self.class == NetworksPlugin::Network
  end
  def network_node?
    self.class == NetworksPlugin::Node
  end

  # FIXME: use materialized path for performance
  def networks
    self.network_node_child_relations.map do |node|
      while not (node = node.parent).network? do end
      node
    end
  end
  def network
    node = self.network_node_child_relation
    while not (node = node.parent).network? do end
    node
  end

end
