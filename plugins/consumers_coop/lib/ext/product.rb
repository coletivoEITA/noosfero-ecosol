require_dependency 'product'

class Product

  has_one :distribution_node, :through => :profile
  def distribution_node
    self.profile.distribution_node
  end

end
