# workaround for plugins' class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class OrdersCyclePluginProductController < SuppliersPluginProductController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include ControllerInheritance
  include SuppliersPlugin::TranslationHelper

  helper SuppliersPlugin::TranslationHelper
  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def cycle_filter
    @cycle = OrdersCyclePlugin::Cycle.find params[:cycle_id]
    @order = OrdersPlugin::Order.find_by_id params[:order_id]

    scope = @cycle.products_for_order
    @products = search_scope(scope).sources_from_2x_products_joins.all

    render :partial => 'order_search', :locals => {
      :order => @order, :cycle => @cycle,
      :products_for_order => @products,
    }
  end

  def edit
    super
    @units = environment.units.all
  end

  def remove_from_order
    @offered_product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    @order = OrdersPlugin::Order.find params[:order_id]
    @ordered_product = @order.products.find_by_product_id @offered_product.id
    @ordered_product.destroy
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

  replace_url_for self.superclass, SuppliersPluginProductController

end
