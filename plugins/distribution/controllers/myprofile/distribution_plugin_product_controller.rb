# workaround for plugin class scope problem
require_dependency 'distribution_plugin/display_helper'

class DistributionPluginProductController < SuppliersPluginProductController

  include DistributionPlugin::ControllerHelper

  no_design_blocks
  before_filter :load_node
  before_filter :set_admin_action

  helper DistributionPlugin::DisplayHelper

  def session_filter
    @session = DistributionPlugin::Session.find params[:session_id]
    @products = @session.products_for_order_by_supplier search_scope.proxy_options
    @order = OrdersPlugin::Order.find_by_id params[:order_id]

    render :partial => 'order_search', :locals => {
      :order => @order, :session => @session,
      :products_for_order_by_supplier => @products,
    }
  end

  def new
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:product][:supplier_id].to_i
    if params[:commit]
      #:supplier_product_id must be set first. it will when params follow the form order with ruby 1.9 ordered hashes
      @product = SuppliersPlugin::DistributedProduct.new :node => @node, :supplier_product_id => params[:product].delete(:supplier_product_id)
      begin
        @product.update_attributes params[:product]
      rescue
      end
    else
      if @supplier
        @product = SuppliersPlugin::DistributedProduct.new :node => @node, :supplier => @supplier
        @product.supplier_product_id = params[:product][:supplier_product_id] if @supplier.node != @node
        not_distributed_products(params[:product][:supplier_product_id])
      end
      render :partial => 'edit', :locals => {:product => @product}
    end
  end

  def add_missing_products
    @supplier = SuppliersPlugin::Supplier.find params[:product][:supplier_id]
    @node.add_supplier_products @supplier
    render :partial => 'distribution_plugin_shared/pagereload'
  end

  def session_edit
    @product = DistributionPlugin::OfferedProduct.find params[:id]
    if request.xhr?
      @product.update_attributes! params[:product]
      respond_to do |format|
        format.js
      end
    end
  end

  def session_destroy
    @product = DistributionPlugin::OfferedProduct.find params[:id]
    @product.destroy!
    flash[:notice] = t('distribution_plugin.controllers.myprofile.product_controller.product_removed_from_')
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :distribution_plugin_product if options[:controller].to_s == 'suppliers_plugin_product'
    super options
  end

end
