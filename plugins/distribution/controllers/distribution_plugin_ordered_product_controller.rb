class DistributionOrderedProductController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def new
    @o_product = DistributionOrderProduct.create!(:order_id => params[:order_id], :session_product_id => params[:session_product_id])
  end

  def edit
    p = DistributionSessionProduct.find_by_id(params[:id])
    p.attributes = params #hum?
  end

  def destroy
    p = DistributionSessionProduct.find_by_id(params[:id])
    p.destroy if p
  end
end
