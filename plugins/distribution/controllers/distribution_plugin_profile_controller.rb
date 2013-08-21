# workaround for plugin class scope problem
require_dependency 'distribution_plugin/display_helper'

class DistributionPluginProfileController < ProfileController

  before_filter :load_node

  helper ApplicationHelper
  helper DistributionPlugin::DisplayHelper

  protected

  include DistributionPlugin::ControllerHelper

end
