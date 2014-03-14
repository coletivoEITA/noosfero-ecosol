class NetworksPlugin::BaseNode < Organization

  self.abstract_class = true

  delegate :parent, :to => :network_node_child_relation, :allow_nil => true
  def parent= node
    self.network_node_child_relations = []
    self.network_node_child_relations.build :parent => node, :child => self
  end

  # is an enterprise as it has products
  def enterprise?
    true
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

  def nodes reload=false
    @nodes = nil if reload
    @nodes ||= self.network_node_parent_relations.all(:conditions => {:child_type => 'NetworksPlugin::Node'}).collect &:child
  end

  def cart_order_supplier_notification_recipients
    if self.networks_settings.orders_forward == 'orders_managers' and self.orders_managers.present?
      self.orders_managers.collect(&:contact_email) << self.contact_email
    else
      profile = if self.network_node? then self.network else self end
      profile.admins.collect(&:contact_email) << profile.contact_email
    end.select{ |email| email.present? }
  end

  protected

  def default_template
    return if self.is_template
    self.environment.network_template
  end

end
