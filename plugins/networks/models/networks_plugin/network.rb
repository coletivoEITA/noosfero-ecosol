class NetworksPlugin::Network < NetworksPlugin::BaseNode

  settings_items :node_template_id

  before_destroy :destroy_dependent

  # used for solr's plugin facets
  def self.type_name
    _('Network')
  end

  def control_panel_settings_button
    {:title => I18n.t('networks_plugin.models.network.settings_button'), :icon => 'edit-profile-enterprise'}
  end

  def network?
    true
  end

  # FIXME: make it recursive
  def network_suppliers
    self.nodes.visible.map{ |n| n.suppliers.except_self }.flatten
  end

  def node_template= template
    self.node_template_id = template.id
    @node_template = template
  end
  def node_template
    @node_template ||= NetworksPlugin::Node.find_by_id self.node_template_id

    unless @node_template
      template = self.environment.network_nodes.build :name => "Network #{self.id} Node template", :visible => false, :is_template => true
      template.parent = self
      template.save!

      template.articles.destroy_all
      template.apply_template self.environment.network_node_template

      self.node_template = template
      self.save!
    end

    @node_template
  end

  def default_template
    return self.environment.enterprise_template if self.is_template
    self.environment.network_template
  end

  protected

  def destroy_dependent
    self.nodes.each do |node|
      node.destroy
    end
    self.network_node_parent_relations.destroy_all

    self.suppliers.each do |supplier|
      # also destroys the associated dummy profile
      supplier.destroy if supplier.dummy?
    end
  end

end
