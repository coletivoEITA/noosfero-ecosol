# workaround for plugins' class scope problem
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

require_dependency 'delivery_plugin' #necessary to load extensions

class OrdersCyclePluginDeliveryOptionController < DeliveryPluginOptionController

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include ControllerInheritance

  no_design_blocks

  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  protected

  replace_url_for self.superclass

end
