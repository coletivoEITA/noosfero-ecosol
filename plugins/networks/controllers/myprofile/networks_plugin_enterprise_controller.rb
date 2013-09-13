# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginEnterpriseController < SuppliersPluginMyprofileController

  helper NetworksPlugin::NetworksDisplayHelper

  def add
    @network = profile
    @node = NetworksPlugin::Node.find params[:id]

    @supplier = SuppliersPlugin::Supplier.new @consumer => @node
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :orders_cycle_plugin_supplier if options[:controller].to_s == 'suppliers_plugin_myprofile'
    options[:controller] = :orders_cycle_plugin_product if options[:controller].to_s == 'suppliers_plugin_product'
    super options
  end

end
