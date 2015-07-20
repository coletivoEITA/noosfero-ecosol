class NetworksPlugin::BaseNode < Enterprise

  has_many :nodes, -> { where profiles: {visible: true} },
    through: :network_node_parent_relations, source: :child_np, class_name: 'NetworksPlugin::Node'

  # if abstract_class is true then it will trigger https://github.com/rails/rails/issues/20871
  #self.abstract_class = true

  delegate :parent, to: :network_node_child_relation, allow_nil: true
  def parent= node
    self.network_node_child_relations = []
    self.network_node_child_relations.build parent: node, child: self
  end

  # replace on subclasses
  def network_suppliers
    self.suppliers.except_self
  end

  def add_enterprise enterprise
    self.class.transaction do
      self.network_node_parent_relations.create! parent: self, child: enterprise
      self.suppliers.create! profile: enterprise
    end
  end

  # FIXME: use acts_as_filesystem
  def hierarchy
    @hierarchy = []
    item = self
    while item
      @hierarchy.unshift(item)
      item = item.parent
    end
    @hierarchy
  end

  def cart_order_supplier_notification_recipients
    if self.networks_settings.orders_forward == 'orders_managers' and self.orders_managers.present?
      self.orders_managers.collect(&:contact_email) << self.contact_email
    else
      profile = if self.network_node? then self.network else self end
      profile.admins.collect(&:contact_email) << profile.contact_email
    end.select{ |email| email.present? }
  end

  def default_template
    raise 'implemented in subclasses'
  end

  def template
    self.default_template
  end

  protected

end
