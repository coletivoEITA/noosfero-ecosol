class DistributionSessionProductController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def new
    @ss_product = DistributionSessionProduct.create!(:product_id => params[:id])
  end

  def edit
    p = DistributionOrderedProduct.find_by_id(params[:id])
    p.attributes = params #hum?
  end

  def destroy
    p = DistributionOrderedProduct.find_by_id(params[:id])
    p.destroy if p
  end
end
