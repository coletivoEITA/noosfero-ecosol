module DistributionPlugin::ControllerHelper

  def set_admin_action
    @admin_action = true
    @admin_edit = @user_node && @user_node != @consumer
  end

  def load_node
    @node = DistributionPluginNode.find_by_profile_id profile.id
    @user_node = DistributionPluginNode.find_or_create current_user.person if current_user
  end

  def content_classes
    "plugin-distribution plugin-distribution-layout"
  end

  def custom_layout?
    true
  end

end
