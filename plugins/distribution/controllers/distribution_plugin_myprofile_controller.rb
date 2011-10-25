class DistributionPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  layout 'distribution_plugin_layouts/default'
  # FIXME: why is this necessary on the subclasses?
  #no_design_blocks
  
  before_filter :load_node

  protected

  def load_node
    @node = DistributionPluginNode.find_or_create(profile)
    @user_node = DistributionPluginNode.find_or_create(current_user.person)
  end

  def set_admin_action
    @admin_action = true
  end

  def layout_contents
    l = [:header]
    l << :admin_sidebar if @admin_action
    l
  end

end
