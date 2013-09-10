class OrdersCyclePluginOrderedProductController < OrdersPluginProductController

  no_design_blocks

  helper OrdersCyclePlugin::DisplayHelper

  def new
    @offered_product = Product.find params[:offered_product_id]
    return render_not_found unless @offered_product
    @consumer = user

    if params[:order_id] == 'new'
      @cycle = @offered_product.cycle
      raise 'Cycle closed for orders' unless @cycle.orders?
      @order = OrdersPlugin::Order.create! :cycle => @cycle, :consumer => consumer
    else
      @order = OrdersPlugin::Order.find params[:order_id]
      @cycle = @order.cycle
    end

    raise 'Order confirmed or cycle is closed for orders' unless @order.open?
    raise 'Please login to place an order' if @consumer.blank?
    raise 'You are not the owner of this order' if @consumer != @order.consumer

    @ordered_product = OrdersPlugin::OrderedProduct.find_by_order_id_and_product_id @order.id, @offered_product.id
    @ordered_product ||= OrdersPlugin::OrderedProduct.new :order => @order, :product => @offered_product
    if set_quantity_asked(params[:quantity_asked] || 1)
      @ordered_product.update_attributes! :quantity_asked => @quantity_asked
    end
  end

  def edit
    return redirect_to params.merge!(:action => :admin_edit) if @admin_edit
    super
    @cycle = @order.cycle
  end

  def admin_edit
    @ordered_product = OrdersPlugin::OrderedProduct.find params[:id]
    @order = @ordered_product.order
    @cycle = @order.cycle

    #update on association for total
    @order.products.each{ |p| p.attributes = params[:ordered_product] if p.id == @ordered_product.id }

    @ordered_product.update_attributes = params[:ordered_product]
  end

  def destroy
    super
    @offered_product = @ordered_product.offered_product
    @cycle = @order.cycle
  end

  protected

  # use superclass instead of child
  def url_for options
    options[:controller] = :orders_cycle_plugin_ordered_product if options[:controller].to_s == 'orders_plugin_product'
    super options
  end

end
