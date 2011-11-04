class DistributionPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  before_filter :load_node
  before_filter :custom_layout
  
  helper ApplicationHelper
  helper DistributionPlugin::DistributionDisplayHelper

  protected

  def load_node
    @node = DistributionPluginNode.find_or_create(profile)
    @user_node = DistributionPluginNode.find_or_create(current_user.person)
  end

  def set_admin_action
    @admin_action = true
  end

  def layout_contents
    return unless custom_layout?
    l = [:header]
    l << :admin_sidebar if @admin_action
    l
  end

  def custom_layout
    self.class.layout 'distribution_plugin_layouts/default'
  end
  def custom_layout?
    true
  end

end
