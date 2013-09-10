# workaround for plugin class scope problem
require_dependency 'orders_cycle_plugin/display_helper'

class OrdersCyclePluginProductController < SuppliersPluginProductController

  no_design_blocks

  helper OrdersCyclePlugin::DisplayHelper

  def cycle_filter
    @cycle = OrdersCyclePlugin::Cycle.find params[:cycle_id]
    @products = @cycle.products_for_order_by_supplier search_scope.proxy_options
    @order = OrdersPlugin::Order.find_by_id params[:order_id]

    render :partial => 'order_search', :locals => {
      :order => @order, :cycle => @cycle,
      :products_for_order_by_supplier => @products,
    }
  end

  def new
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:product][:supplier_id].to_i
    if params[:commit]
      #:supplier_product_id must be set first. it will when params follow the form order with ruby 1.9 ordered hashes
      @product = SuppliersPlugin::DistributedProduct.new :profile => profile, :supplier_product_id => params[:product].delete(:supplier_product_id)
      begin
        @product.update_attributes params[:product]
      rescue
      end
    else
      if @supplier
        @product = SuppliersPlugin::DistributedProduct.new :profile => profile, :supplier => @supplier
        @product.supplier_product_id = params[:product][:supplier_product_id] if @supplier.profile != profile
        not_distributed_products(params[:product][:supplier_product_id])
      end
      render :partial => 'edit', :locals => {:product => @product}
    end
  end

  def cycle_edit
    @product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    if request.xhr?
      @product.update_attributes! params[:product]
      respond_to do |format|
        format.js
      end
    end
  end

  def cycle_destroy
    @product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    @product.destroy!
    flash[:notice] = t('orders_cycle_plugin.controllers.myprofile.product_controller.product_removed_from_')
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :orders_cycle_plugin_product if options[:controller].to_s == 'suppliers_plugin_product'
    options[:controller] = :orders_cycle_plugin_supplier if options[:controller].to_s == 'suppliers_plugin_myprofile'
    super options
  end

end
