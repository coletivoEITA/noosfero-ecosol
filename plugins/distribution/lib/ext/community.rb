require_dependency 'community'

class Community

  has_many :products

  def add_member(person)
    super(person)

    if self.node.collective?
      consumer_node = DistributionPluginNode.find_or_create person
      self.node.add_consumer consumer_node
    end
  end

  def remove_member(person)
    super(person)

    consumer_node = DistributionPluginNode.find_or_create person
    self.node.remove_consumer consumer_node
  end

end
