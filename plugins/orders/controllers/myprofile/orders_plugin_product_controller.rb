# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPluginProductController < MyProfileController

  no_design_blocks

  helper OrdersPlugin::PriceHelper
  helper OrdersPlugin::OrdersDisplayHelper

  def edit
    @consumer = user
    @ordered_product = OrdersPlugin::OrderedProduct.find params[:id]
    @offered_product = @ordered_product.offered_product
    @order = @ordered_product.order

    raise 'Order confirmed or cycle is closed for orders' unless @order.open?
    raise 'Please login to place an order' if @consumer.blank?
    raise 'You are not the owner of this order' if @consumer != @order.consumer

    if set_quantity_asked params[:ordered_product][:quantity_asked]
      params[:ordered_product][:quantity_asked] = @quantity_asked
      @ordered_product.update_attributes! params[:ordered_product]
    end
  end

  def destroy
    @ordered_product = OrdersPlugin::OrderedProduct.find params[:id]
    @product = @ordered_product.product
    @order = @ordered_product.order

    @ordered_product.destroy
  end

  protected

  def set_quantity_asked value
    @quantity_asked = CurrencyHelper.parse_localized_number value

    if @quantity_asked > 0
      min = @ordered_product.product.minimum_selleable rescue nil
      if min and @quantity_asked < min
        @quantity_asked = min
        @quantity_asked_less_than_minimum = @ordered_product.id || true
      end
    else
      @ordered_product.destroy if @ordered_product
      render :action => :destroy
      @quantity_asked = nil
    end

    @quantity_asked
  end

end
