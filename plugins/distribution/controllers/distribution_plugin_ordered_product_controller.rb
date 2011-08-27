class DistributionPluginOrderedProductController < DistributionPluginMyprofileController
  no_design_blocks

  def new
    @o_product = DistributionPluginOrderedProduct.create!(:order_id => params[:order_id],
                                                          :session_product_id => params[:session_product_id],
                                                          :quantity_asked => 0)
    @order = @o_product.order
    @first = @order.ordered_products.count == 1
  end

  #'add_product' this method shows the product view. Actually, from there you add a product.
  def add_product
    @session_product = DistributionPluginSessionProduct.find params[:id]
    @order = DistributionPluginOrder.find params[:order_id]
  end

  def edit
    @ordered_product = DistributionPluginOrderedProduct.find(params[:id])
  end

  def destroy
    p = DistributionPluginOrderedProduct.find(params[:id])
    @o_product = p
    p.destroy if p
    @order = p.order
  end

  def update_quantity
    @ordered_product = DistributionPluginOrderedProduct.find(params[:id])
    @ordered_product.quantity_asked = params[:quantity_asked]
    @ordered_product.save!
    @order = @ordered_product.order
  end
end
