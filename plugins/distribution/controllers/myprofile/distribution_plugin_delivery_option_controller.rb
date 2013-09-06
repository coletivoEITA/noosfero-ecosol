require_dependency 'delivery_plugin' #necessary to load extensions

class DistributionPluginDeliveryOptionController < DeliveryPluginOptionController

  include DistributionPlugin::ControllerHelper

  no_design_blocks
  before_filter :load_node
  before_filter :set_admin_action

  helper ApplicationHelper
  helper DistributionPlugin::DistributionDisplayHelper

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :distribution_plugin_delivery_option if options[:controller].to_s == 'delivery_plugin_option'
    super options
  end

end
