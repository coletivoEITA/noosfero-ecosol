class DistributionPluginMyprofileController < MyProfileController

  before_filter :load_node

  helper ApplicationHelper
  helper DistributionPlugin::DistributionDisplayHelper

  protected

  include DistributionPlugin::ControllerHelper

end
