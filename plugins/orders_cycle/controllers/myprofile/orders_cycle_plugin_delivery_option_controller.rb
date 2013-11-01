# workaround for plugins' class scope problem
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

require_dependency 'delivery_plugin' #necessary to load extensions

class OrdersCyclePluginDeliveryOptionController < DeliveryPluginOptionController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include ControllerInheritance
  include SuppliersPlugin::TranslationHelper

  helper SuppliersPlugin::TranslationHelper
  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  protected

  replace_url_for self.superclass

end
