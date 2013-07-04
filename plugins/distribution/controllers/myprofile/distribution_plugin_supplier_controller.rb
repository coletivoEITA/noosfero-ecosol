class DistributionPluginSupplierController < SuppliersPluginMyprofileController

  no_design_blocks

  before_filter :load_node
  before_filter :set_admin_action

  helper ApplicationHelper
  helper DistributionPlugin::DistributionDisplayHelper

  protected

  include DistributionPlugin::ControllerHelper

end
