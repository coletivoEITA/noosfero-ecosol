# workaround for plugins' class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class OrdersCyclePluginSupplierController < SuppliersPluginMyprofileController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include ControllerInheritance
  include SuppliersPlugin::TranslationHelper

  protect 'edit_profile', :profile

  helper SuppliersPlugin::TranslationHelper
  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def margin_change
    super
    profile.orders_cycles_products_default_margins if params[:apply_to_open_cycles]
  end

  protected

  replace_url_for self.superclass, SuppliersPluginProductController

end
