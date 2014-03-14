# workaround for plugins' class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class OrdersCyclePluginSupplierController < SuppliersPluginMyprofileController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  protect 'edit_profile', :profile

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def margin_change
    super
    profile.orders_cycles_products_default_margins if params[:apply_to_open_cycles]
  end

  protected

  include ControllerInheritance
  replace_url_for self.superclass => self, SuppliersPluginProductController => self

end
