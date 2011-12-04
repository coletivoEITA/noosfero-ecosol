class DistributionPluginOrderedProductController < DistributionPluginMyprofileController
  no_design_blocks

  def new
    @order = DistributionPluginOrder.find params[:order_id]
    raise 'Order confirmed or cycle is closed for orders' unless @order.open?

    @session_product = DistributionPluginProduct.find params[:session_product_id]
    @ordered_product = DistributionPluginOrderedProduct.find_by_order_id_and_session_product_id(@order.id, @session_product.id)
    if @ordered_product.nil?
      @quantity_asked = params[:quantity_asked] || 1
      @ordered_product = DistributionPluginOrderedProduct.create! :order_id => @order.id, :session_product_id => @session_product.id, :quantity_asked => @quantity_asked
    else
      @quantity_asked = params[:quantity_asked].to_i
      if @quantity_asked == 0
        @ordered_product.destroy
        render :action => :destroy
      else
        @ordered_product.update_attributes! :quantity_asked => @quantity_asked
      end
    end
  end

  def edit
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
    raise 'Order confirmed or cycle is closed for orders' unless @order.open?
 
    if params[:ordered_product][:quantity_asked].to_i == 0
      @ordered_product.destroy
      render :action => :destroy
    else
      @ordered_product.update_attributes params[:ordered_product]
    end
  end

  def admin_edit
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
    #update on association for total
    @order.products.each{ |p| p.attributes = params[:ordered_product] if p.id == @ordered_product.id }
    @ordered_product.attributes = params[:ordered_product]
  end

  def destroy
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
    @ordered_product.destroy
  end

  def session_destroy
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
  end

end
