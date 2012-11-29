module DistributionPlugin::DistributionLayoutHelper

  def load_node
    @node = DistributionPluginNode.find_or_create profile
    @user_node = DistributionPluginNode.find_or_create current_user.person
  end

  def render_header
    return unless @node.enabled?
    render :file => 'distribution_plugin_layouts/default'
  end

end
