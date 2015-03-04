# workaround: necessary to load extensions
require_dependency 'delivery_plugin'

class OrdersCyclePluginDeliveryOptionController < DeliveryPluginOptionController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::DisplayHelper

  protected

  extend ControllerInheritance::ClassMethods
  hmvc OrdersCyclePlugin, orders_context: OrdersCyclePlugin

end
