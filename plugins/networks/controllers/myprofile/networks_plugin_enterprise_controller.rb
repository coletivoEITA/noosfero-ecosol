# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginEnterpriseController < SuppliersPluginMyprofileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:associate, :destroy]

  helper NetworksPlugin::NetworksDisplayHelper

  def new
    @new_supplier.identifier_from_name = true
    @node = profile
    super
    @node.network_node_parent_relations.create! :parent => @node, :child => @new_supplier.profile
  end

  def add
    @node = profile
    super
    @node.network_node_parent_relations.create! :parent => @node, :child => @enterprise
  end

  def destroy
    @supplier = @node.suppliers.find params[:id]
    @enterprise = @supplier.profile
    @relation = @enterprise.network_node_child_relations.where(:parent_id => @node.id).first

    ActiveRecord::Base.transaction do
      @supplier.destroy
      @relation.destroy
    end
  end

  def associate
    @new_supplier = SuppliersPlugin::Supplier.new_dummy :consumer => @node
  end

  def disassociate
    @enterprise = profile
    @network = environment.networks.find params[:id]
    @enterprise.network_disassociate @network
    @enterprise.reload
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

  extend ControllerInheritance::ClassMethods
  hmvc NetworksPlugin

end
