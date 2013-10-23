# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginEnterpriseController < SuppliersPluginMyprofileController

  include ControllerInheritance
  replace_url_for self.superclass
  include NetworksPlugin::TranslationHelper

  helper NetworksPlugin::NetworksDisplayHelper

  def new
    super
  end

  def add
    super
  end

  def associate
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network

    @new_supplier = SuppliersPlugin::Supplier.new_dummy :consumer => @node

    render :layout => false
  end

  protected

end
