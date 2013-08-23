# workaround for plugin class scope problem
require_dependency 'distribution_plugin/display_helper'

class DistributionPluginSupplierController < SuppliersPluginMyprofileController

  include DistributionPlugin::ControllerHelper

  no_design_blocks
  before_filter :load_node
  before_filter :set_admin_action

  helper ApplicationHelper
  helper DistributionPlugin::DisplayHelper

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :distribution_plugin_supplier if options[:controller].to_s == 'suppliers_plugin_supplier'
    super options
  end

end
