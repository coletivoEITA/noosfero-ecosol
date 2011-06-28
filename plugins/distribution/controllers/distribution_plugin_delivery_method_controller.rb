class DistributionPluginDeliveryMethodController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
  end

  def new
    @delivery_method = DistributionPluginDeliveryMethod.create!(:product_id => params[:id])
  end

  def edit
    @delivery_method = DistributionPluginDeliveryMethod.find_by_id(params[:id])
  end

  def destroy
    dm = DistributionPluginDeliveryMethod.find_by_id(params[:id])
    @delivery_method_id = dm.id
    dm.destroy if dm
    flash[:notice] = _('Delivery method removed from session')
  end
end
