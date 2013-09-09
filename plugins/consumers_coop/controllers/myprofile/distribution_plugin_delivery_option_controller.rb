require_dependency 'delivery_plugin' #necessary to load extensions

class ConsumersCoopPluginDeliveryOptionController < DeliveryPluginOptionController

  include ConsumersCoopPlugin::ControllerHelper

  no_design_blocks
  before_filter :set_admin_action

  helper ConsumersCoopPlugin::DisplayHelper

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :consumers_coop_plugin_delivery_option if options[:controller].to_s == 'delivery_plugin_option'
    super options
  end

end
