class DistributionPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  no_design_blocks

  before_filter :load_node

  def load_node
    @node = DistributionPluginNode.find_or_create(profile)
  end

end
