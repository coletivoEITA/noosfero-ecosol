# workaround for plugin class scope problem
require_dependency 'orders_cycle_plugin/display_helper'

class OrdersCyclePluginSupplierController < SuppliersPluginMyprofileController

  no_design_blocks

  helper OrdersCyclePlugin::DisplayHelper

  def margin_change
    super
    profile.orders_cycles_products_default_margins if params[:apply_to_open_cycles]
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :consumers_coop_plugin_supplier if options[:controller].to_s == 'suppliers_plugin_supplier'
    super options
  end

end
