# workaround for plugins' class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class OrdersCyclePluginSupplierController < SuppliersPluginMyprofileController

  include ControllerInheritance
  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper

  no_design_blocks

  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def margin_change
    super
    profile.orders_cycles_products_default_margins if params[:apply_to_open_cycles]
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :orders_cycle_plugin_supplier if options[:controller].to_s == 'suppliers_plugin_myprofile'
    options[:controller] = :orders_cycle_plugin_product if options[:controller].to_s == 'suppliers_plugin_product'
    super options
  end

end
