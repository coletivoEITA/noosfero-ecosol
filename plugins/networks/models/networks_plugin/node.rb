class NetworksPlugin::Node < NetworksPlugin::BaseNode

  ParentDelimiter = '::'

  before_validation :name_to_identifier
  after_destroy :assign_dependent_to_parent

  delegate :admins, :to => :network

  protected

  def name_to_identifier
    self.identifier = "#{self.parent.identifier}#{ParentDelimiter}#{self.name.to_slug}"
  end

  def assign_dependent_to_parent
    self.network_node_parent_relations.each do |relation|
      relation.parent = self.parent
      relation.save!
    end
    # 'suppliers' has_many is frozen, so create new ones
    self.suppliers.each do |supplier|
      next if supplier.self?
      supplier.dont_destroy_dummy = true
      new_supplier = self.parent.suppliers.build :profile => supplier.profile
      new_supplier.attributes = supplier.attributes
      new_supplier.consumer = self.parent
      # Avoid "can't modify frozen hash" error
      new_supplier.send :create_without_callbacks
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
