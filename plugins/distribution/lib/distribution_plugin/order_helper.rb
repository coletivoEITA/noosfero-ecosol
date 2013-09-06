# workaround for plugin class scope problem
require_dependency 'distribution_plugin/display_helper'

module DistributionPlugin::OrderHelper

  protected

  include DistributionPlugin::DistributionDisplayHelper

end
