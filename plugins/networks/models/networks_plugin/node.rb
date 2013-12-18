class NetworksPlugin::Node < NetworksPlugin::BaseNode

  before_validation :generate_identifier
  before_destroy :assign_dependent_to_parent

  def node?
    true
  end

  protected

  def generate_identifier
    self.identifier = Digest::MD5.hexdigest rand.to_s
  end

  def assign_dependent_to_parent
    self.network_node_parent_relations.each do |relation|
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

  def default_template
    self.network
  end

  # don't copy network's articles
  def insert_default_article_set
    self.home_page = EnterpriseHomepage.create! :profile => self, :accept_comments => false
    self.save!
  end

end
