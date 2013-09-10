require_dependency 'delivery_plugin' #necessary to load extensions

class OrdersCyclePluginDeliveryOptionController < DeliveryPluginOptionController

  no_design_blocks

  helper OrdersCyclePlugin::DisplayHelper

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :orders_cycle_plugin_delivery_option if options[:controller].to_s == 'delivery_plugin_option'
    super options
  end

end
