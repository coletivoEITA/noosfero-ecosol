class DistributionPluginSessionProductController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def new
    @ss_product = DistributionPluginSessionProduct.create!(:product_id => params[:id])
  end

  def edit
    p = DistributionPluginSessionProduct.find_by_id(params[:id])
    p.attributes = params #hum?
  end

  def destroy
    p = DistributionPluginSessionProduct.find_by_id(params[:id])
    @product_id = p.id
    p.destroy if p
    flash[:notice] = _('Product removed from session')
  end
end
