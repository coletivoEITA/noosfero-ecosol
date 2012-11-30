module DistributionPlugin::DistributionLayoutHelper

  def load_node
    @node = DistributionPluginNode.find_by_profile_id profile.id if profile
    @user_node = DistributionPluginNode.find_or_create current_user.person if current_user
  end

  def render_header
    return unless @node and @node.collective?
    render :file => 'distribution_plugin_layouts/default'
  end

end
