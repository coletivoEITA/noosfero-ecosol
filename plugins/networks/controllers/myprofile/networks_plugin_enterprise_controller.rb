# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginEnterpriseController < SuppliersPluginMyprofileController

  include ControllerInheritance

  helper NetworksPlugin::NetworksDisplayHelper

  def new
    super
    render :partial => 'suppliers_plugin_myprofile/pagereload'
  end


  def add
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network

    @new_supplier = SuppliersPlugin::Supplier.new_dummy :consumer => @node

    render :layout => false
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :networks_plugin_enterprise if options[:controller].to_s == 'suppliers_plugin_myprofile'
    super options
  end

end
