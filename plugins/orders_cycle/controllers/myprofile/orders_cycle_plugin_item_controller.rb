# workaround for plugins' class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

class OrdersCyclePluginItemController < OrdersPluginItemController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersCyclePlugin::OrdersCycleDisplayHelper

  def new
    @offered_product = Product.find params[:offered_product_id]
    @consumer = user
    return render_not_found unless @offered_product
    raise 'Please login to place an order' if @consumer.blank?

    if params[:order_id] == 'new'
      @cycle = @offered_product.cycle
      raise 'Cycle closed for orders' unless @cycle.orders? and not profile.has_admin? user
      @order = OrdersPlugin::Order.create! :cycle => @cycle, :consumer => consumer
    else
      @order = OrdersPlugin::Order.find params[:order_id]
      @cycle = @order.cycle
      raise 'Order confirmed or cycle is closed for orders' unless @order.open?
      raise 'You are not the owner of this order' unless @order.may_edit? @consumer
    end

    @item = OrdersPlugin::Item.find_by_order_id_and_product_id @order.id, @offered_product.id
    @item ||= OrdersPlugin::Item.new :order => @order, :product => @offered_product
    if set_quantity_asked(params[:quantity_asked] || 1)
      @item.update_attributes! :quantity_asked => @quantity_asked
    end
  end

  def edit
    return redirect_to params.merge!(:action => :admin_edit) if @admin_edit
    super
    @cycle = @order.cycle
  end

  def admin_edit
    @item = OrdersPlugin::Item.find params[:id]
    @order = @item.order
    @cycle = @order.cycle

    #update on association for total
    @order.items.each{ |i| i.attributes = params[:item] if i.id == @item.id }

    @item.update_attributes = params[:item]
  end

  def destroy
    super
    @offered_product = @product
    @cycle = @order.cycle
  end

  protected

  include ControllerInheritance
  replace_url_for self.superclass => self

end
