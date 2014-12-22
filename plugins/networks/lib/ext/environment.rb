require_dependency 'environment'

class Environment

  has_many :networks, :class_name => 'NetworksPlugin::Network'
  has_many :network_nodes, :class_name => 'NetworksPlugin::Node'

  settings_items :network_template_id
  settings_items :network_node_template_id

  def network_template
    @network_template ||= self.networks.find_by_id self.network_template_id

    unless @network_template
      theme = if Theme.system_themes.collect(&:id).include?('networks') then 'networks' else nil end

      template = self.networks.create! :name => 'Network template', :identifier => "#{self.name.to_slug}_network_template", :visible => false, :is_template => true

      template.theme = theme
      template.layout_template = 'leftbar'
      #template.home_page = EnterpriseHomepage.create! :profile => template
      template.save!

      self.network_template = template
      self.save!
    end

    @network_template
  end
  def network_template= template
    self.network_template_id = template.id
    @network_template = template
  end

  def network_node_template
    @network_node_template ||= self.network_nodes.find_by_id self.network_node_template_id

    unless @network_node_template
      template = self.network_nodes.create! :parent => self.network_template, :name => 'Network Node template', :visible => false, :is_template => true

      self.network_node_template = template
      self.save
    end

    @network_node_template
  end
  def network_node_template= template
    self.network_node_template_id = template.id
    @network_node_template = template
  end

end
