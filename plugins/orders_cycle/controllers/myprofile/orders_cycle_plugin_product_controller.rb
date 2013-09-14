# workaround for plugins' class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class OrdersCyclePluginProductController < SuppliersPluginProductController

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper

  no_design_blocks

  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def cycle_filter
    @cycle = OrdersCyclePlugin::Cycle.find params[:cycle_id]
    @products = search_scope(@cycle.products_for_order)
    @order = OrdersPlugin::Order.find_by_id params[:order_id]
    @product_categories = Product.product_categories_of @products

    render :partial => 'order_search', :locals => {
      :order => @order, :cycle => @cycle,
      :products_for_order => @products,
    }
  end

  def edit
    @product = SuppliersPlugin::DistributedProduct.find params[:id]
    @product.update_attributes params[:product]
    @units = Unit.all
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
