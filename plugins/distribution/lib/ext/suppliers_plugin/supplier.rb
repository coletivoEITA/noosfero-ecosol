require_dependency 'suppliers_plugin/supplier'

class SuppliersPlugin::Supplier

  has_one :node, :through => :profile
  def node
    self.profile.node
  end

  has_one :consumer_node, :through => :consumer_node
  def consumer_node
    self.consumer.node
  end

end

