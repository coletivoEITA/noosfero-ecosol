# workaround for plugin class scope problem
require_dependency 'consumers_coop_plugin/display_helper'

class ConsumersCoopPluginSupplierController < SuppliersPluginMyprofileController

  include ConsumersCoopPlugin::ControllerHelper

  no_design_blocks
  before_filter :set_admin_action

  helper ApplicationHelper
  helper ConsumersCoopPlugin::DisplayHelper

  def margin_change
    super
    @node.default_open_cycles_products_margins if params[:apply_to_open_cycles]
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :consumers_coop_plugin_supplier if options[:controller].to_s == 'suppliers_plugin_supplier'
    super options
  end

end
