class NetworksPlugin::Node < NetworksPlugin::BaseNode

  before_validation :generate_identifier

  before_destroy :assign_dependent_to_parent

  def network
    network = self
    while not (network = network.parent).network? do end
    network
  end

  def node?
    true
  end

  protected

  def generate_identifier
    self.identifier = Digest::MD5.hexdigest rand.to_s
  end

  def assign_dependent_to_parent
    self.as_parent_relations.each do |relation|
      relation.parent = self.parent
      relation.save!
    end
    # suppliers are frozen, so create new ones
    self.suppliers.each do |supplier|
      next if supplier.self?
      supplier.dont_destroy_dummy = true
      new_supplier = self.parent.suppliers.build :profile => supplier.profile
      new_supplier.attributes = supplier.attributes
      new_supplier.consumer = self.parent
      new_supplier.save!
    end
  end

end
