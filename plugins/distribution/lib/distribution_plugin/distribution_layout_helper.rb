module DistributionPlugin::DistributionLayoutHelper

  def load_node
    @node = DistributionPluginNode.find_by_profile_id profile.id if profile
    @user_node = DistributionPluginNode.find_or_create current_user.person if current_user
  end

  def render_header
    return unless @node and @node.collective?
    output = render :file => 'distribution_plugin_layouts/default'
    output += render :file => 'distribution_plugin_gadgets/sessions' if on_homepage?
    output
  end

  protected

  # FIXME: workaround to fix Profile#is_on_homepage?
  def on_homepage?
    @node.profile.is_on_homepage?(request.path, @page) or request.path == "/profile/#{@node.profile.identifier}"
  end

end
