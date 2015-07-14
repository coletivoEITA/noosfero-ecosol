require_dependency 'enterprise'

class Enterprise

  has_many :network_node_child_relations, -> {
    includes(:parent).
    where("parent_type = 'NetworksPlugin::Node' OR parent_type = 'NetworksPlugin::Network'")
  }, foreign_key: :child_id, class_name: 'SubOrganizationsPlugin::Relation', dependent: :destroy

  has_many :network_node_parent_relations, -> {
    includes(:child).
    where("child_type = 'NetworksPlugin::Node' OR child_type = 'NetworksPlugin::Network'")
  }, foreign_key: :parent_id, class_name: 'SubOrganizationsPlugin::Relation'

  def network_node_child_relation
    self.network_node_child_relations.first
  end

  def networks_settings
    @networks_settings ||= Noosfero::Plugin::Settings.new self, NetworksPlugin
  end

  def network_disassociate network
    ActiveRecord::Base.transaction do
      self.network_node_child_relations.each do |relation|
        node = relation.parent
        if (node.network? and node == network) or (node.network_node? and node.network == network)
          self.consumers.of_consumer(node).first.destroy
          relation.destroy
        end
      end
    end
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
    return node if node.nil?
    while not (node = node.parent).network? do end
    node
  end

end
