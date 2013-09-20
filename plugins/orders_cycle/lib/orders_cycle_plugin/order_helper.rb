# workaround for plugin class scope problem
require_dependency 'orders_cycle_plugin/display_helper'

module OrdersCyclePlugin::OrderHelper

  protected

  include OrdersCyclePlugin::DisplayHelper

end
