# workaround for plugin class scope problem
require_dependency 'distribution_plugin/display_helper'

class DistributionPluginProfileController < ProfileController

  include DistributionPlugin::ControllerHelper

  before_filter :load_node

  helper ApplicationHelper
  helper DistributionPlugin::DisplayHelper

  protected

end
