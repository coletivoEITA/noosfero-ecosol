class NetworksPluginEnterpriseController < SuppliersPluginMyprofileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:associate, :destroy]
  before_filter :load_node_and_network, :only => [:new, :add]

  helper NetworksPlugin::DisplayHelper

  def new
    @new_supplier.identifier_from_name = true
    ActiveRecord::Base.transaction do
      super
      @node.network_node_parent_relations.create! :parent => @node, :child => @new_supplier.profile
    end
  end

  def add
    ActiveRecord::Base.transaction do
      super
      @node.network_node_parent_relations.create! :parent => @node, :child => @enterprise
    end
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

  def load_node_and_network
    @node = profile
    @network = @node.network || @node
  end

  extend HMVC::ClassMethods
  hmvc NetworksPlugin

end
