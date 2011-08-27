class DistributionPluginSessionProductController < DistributionPluginMyprofileController
  no_design_blocks

  helper DistributionPlugin::SessionHelper

  def new
    @ss_product = DistributionPluginSessionProduct.create!(:product_id => params[:id])
  end

  def edit
    @product = DistributionPluginSessionProduct.find_by_id(params[:id])
    if request.post?
      @product.update_attributes(params[:product])
      @product.save!
    end
    if request.xhr?
      render :partial => 'distribution_plugin_session/session_product', :locals => {:p => @product}, :layout => false
    end
  end

  def destroy
    p = DistributionPluginSessionProduct.find_by_id(params[:id])
    @product_id = p.id
    p.destroy if p
    flash[:notice] = _('Product removed from session')
  end
end
