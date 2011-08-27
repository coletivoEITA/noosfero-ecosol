class DistributionPluginConsumerController < DistributionPluginMyprofileController
  no_design_blocks

  def index
    @node = DistributionPluginNode.find_by_profile_id(profile.id)
  end

end
