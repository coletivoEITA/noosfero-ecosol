class NetworksPlugin::Node < NetworksPlugin::BaseNode

  ParentDelimiter = '::'

  before_validation :name_to_identifier
  after_destroy :assign_dependent_to_parent

  delegate :admins, :to => :network, :allow_nil => true

  # used for solr's plugin facets
  def self.type_name
    _('Node')
  end

  def default_template
    return self.environment.network_template if self.is_template
    self.network.node_template
  end

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
      new_supplier.save run_callbacks: false
    end
  end

  # don't copy network's articles
  def insert_default_article_set
    self.home_page = EnterpriseHomepage.create! :profile => self, :accept_comments => false
    self.save!
  end

end
