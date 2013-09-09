# workaround for plugin class scope problem
require_dependency 'consumers_coop_plugin/display_helper'

module OrdersCyclePlugin::OrderHelper

  protected

  include OrdersCyclePlugin::DisplayHelper

end
