class DistributionPluginOrderedProductController < DistributionPluginMyprofileController
  no_design_blocks

  def new
    @order = DistributionPluginOrder.find params[:order_id]
    raise 'Order confirmed or cycle is closed for orders' unless @order.open?

    @session_product = DistributionPluginProduct.find params[:session_product_id]
    @quantity_asked = params[:quantity_asked] || 1

    @ordered_product = DistributionPluginOrderedProduct.find_by_order_id_and_session_product_id(@order.id, @session_product.id)
    if @ordered_product.nil?
      @ordered_product = DistributionPluginOrderedProduct.create!(:order_id => @order.id, :session_product_id => @session_product.id, :quantity_asked => @quantity_asked)
    end
  end

  def edit
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
    raise 'Order confirmed or cycle is closed for orders' unless @order.open?

    @ordered_product.update_attributes params[:ordered_product]
  end

  def admin_edit
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
  end

  def destroy
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = p.order
  end

  def session_destroy
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = p.order
  end

end
