class DistributionPluginOrderedProductController < DistributionPluginMyprofileController
  no_design_blocks

  def new
    @order = DistributionPluginOrder.find params[:order_id]
    @session_product = DistributionPluginProduct.find params[:session_product_id]
    @quantity_asked = params[:quantity_asked] || 1

    @ordered_product = DistributionPluginOrderedProduct.find_by_order_id_and_session_product_id(@order.id, @session_product.id)
    if @ordered_product.nil?
      @ordered_product = DistributionPluginOrderedProduct.create!(:order_id => @order.id, :session_product_id => @session_product.id, :quantity_asked => @quantity_asked)
    else
      redirect_to :action => :edit, :id => @ordered_product.id, :ordered_product => {:quantity_asked => @quantity_asked}
    end
  end

  def edit
    @ordered_product = DistributionPluginOrderedProduct.find params[:id]
    @order = @ordered_product.order
    @ordered_product.update_attributes params[:ordered_product]
  end

  def report_products
    @ordered_products = DistributionPluginOrderedProduct.find(:all, :conditions => ["distribution_plugin_products.session_id = ?" ,params[:id]], :include => :product)
  end

  def destroy
    p = DistributionPluginOrderedProduct.find params[:id]
    @ordered_product = p
    @order = p.order
    p.destroy if p
  end

end
