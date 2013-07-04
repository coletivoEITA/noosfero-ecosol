require_dependency 'suppliers_plugin/supplier'

class SuppliersPlugin::Supplier

  has_one :node, :through => :profile
  def node
    self.profile.distribution_node
  end

  has_one :consumer_node, :through => :consumer_node
  def consumer_node
    self.consumer.distribution_node
  end

end

