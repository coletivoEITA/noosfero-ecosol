class DistributionPluginProductController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  no_design_blocks
  layout false

  def edit
    @d_product = DistributionPluginProduct.find_by_id(params[:id])
    @n_product = @d_product.product
    @node = @d_product.node
  end
end
