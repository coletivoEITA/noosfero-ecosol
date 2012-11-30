class DistributionPluginProfileController < ProfileController

  before_filter :load_node

  helper ApplicationHelper
  helper DistributionPlugin::DistributionDisplayHelper

  protected

  def load_node
    @node = DistributionPluginNode.find_or_create profile
    @user_node = DistributionPluginNode.find_or_create current_user.person if current_user
  end

  def before_contents
  end

  def content_classes
    "plugin-distribution plugin-distribution-layout"
  end

  def custom_layout?
    true
  end

end
