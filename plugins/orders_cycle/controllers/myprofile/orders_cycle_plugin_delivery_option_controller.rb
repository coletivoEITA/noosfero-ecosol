# workaround for plugins' class scope problem
require_dependency 'delivery_plugin'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

require_dependency 'delivery_plugin' #necessary to load extensions

class OrdersCyclePluginDeliveryOptionController < DeliveryPluginOptionController

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper

  no_design_blocks

  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :orders_cycle_plugin_delivery_option if options[:controller].to_s == 'delivery_plugin_option'
    super options
  end

end
