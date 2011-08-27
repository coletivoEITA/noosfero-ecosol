class DistributionPluginProductController < DistributionPluginMyprofileController
  no_design_blocks

  def edit
    @d_product = DistributionPluginProduct.find_by_id(params[:id])
    @n_product = @d_product.product
    @node = @d_product.node
    render :layout => false
  end

end
