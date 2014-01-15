require_dependency 'environment'

class Environment

  has_many :networks, :class_name => 'NetworksPlugin::Network'

  def network_template
    @network_template ||= NetworksPlugin::Network.find_by_id settings[:network_template_id]
    unless @network_template
      theme = if Theme.system_themes.collect(&:id).include?('networks') then 'networks' else nil end
      @network_template = self.networks.create! :name => 'Network template', :identifier => "#{self.name.to_slug}_network_template", :visible => false, :is_template => true
      @network_template.apply_template self.enterprise_template
      @network_template.attributes = {:theme => theme, :layout_template => 'leftbar'}
      @network_template.save!

      @network_template.home_page.type = 'EnterpriseHomepage'
      @network_template.home_page.save

      self.network_template = @network_template
      self.save
    end
    @network_template
  end

  def network_template= template
    settings[:network_template_id] = template.id
    @network_template = template
  end

end
