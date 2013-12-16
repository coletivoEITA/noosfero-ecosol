module NetworksPlugin::LayoutHelper

  protected

  def network_node?
    profile and profile.is_a?(NetworksPlugin::BaseNode)
  end

  def network_header
    render 'networks_plugin_layouts/header'
  end

end
