class DistributionPluginParcelController < DistributionPluginMyprofileController

  no_design_blocks
  before_filter :set_admin_action, :only => [:index]

  def index
    @parcels = @node.parcels
  end

end
