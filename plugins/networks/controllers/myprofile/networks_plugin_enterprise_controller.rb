# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginEnterpriseController < SuppliersPluginMyprofileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:associate, :destroy]

  helper NetworksPlugin::NetworksDisplayHelper

  def new
    @node = profile
    super
    @node.network_node_parent_relations.create! :parent => @node, :child => @new_supplier.profile
  end

  def add
    @node = profile
    super
    @node.network_node_parent_relations.create! :parent => @node, :child => @enterprise
  end

  def associate
    @new_supplier = SuppliersPlugin::Supplier.new_dummy :consumer => @node
    render :layout => false
  end

  def destroy
    @profile = @node
    super
  end

  def edit
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:node_id]) || @network
    @supplier = @node.suppliers.find params[:id]
  end

  def join
    @network = profile
  end

  protected

  def load_node
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network
  end

  include ControllerInheritance
  replace_url_for self.superclass => self

end
