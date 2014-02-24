# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPluginItemController < MyProfileController

  no_design_blocks

  helper OrdersPlugin::OrdersDisplayHelper

  def edit
    @consumer = user
    @item = OrdersPlugin::Item.find params[:id]
    @offered_product = @item.offered_product
    @order = @item.order

    unless @order.may_edit? @consumer
      raise 'Order confirmed or cycle is closed for orders' unless @order.open?
      raise 'Please login to place an order' if @consumer.blank?
      raise 'You are not the owner of this order' if @consumer != @order.consumer
    end

    if set_quantity_asked params[:item][:quantity_asked]
      params[:item][:quantity_asked] = @quantity_asked
      @item.update_attributes! params[:item]
    end
  end

  def destroy
    @item = OrdersPlugin::Item.find params[:id]
    @product = @item.product
    @order = @item.order

    @item.destroy
  end

  protected

  def set_quantity_asked value
    @quantity_asked = CurrencyHelper.parse_localized_number value

    if @quantity_asked > 0
      min = @item.product.minimum_selleable rescue nil
      if min and @quantity_asked < min
        @quantity_asked = min
        @quantity_asked_less_than_minimum = @item.id || true
      end
    else
      @item.destroy if @item
      @quantity_asked = nil
      render :action => :destroy
    end

    @quantity_asked
  end

end
