class DistributionPluginDeliveryMethodController < DistributionPluginMyprofileController
  no_design_blocks

  def index
  end

  def new
    if request.post?
      if params[:session_id]
        @for_session = true
        @session = DistributionPluginSession.find(params[:session_id])
        @delivery_method = DistributionPluginDeliveryMethod.create!(params[:delivery_method].merge({:node_id => @session.node_id}))
        @delivery_option = DistributionPluginDeliveryOption.create!(:session => @session, :delivery_method => @delivery_method)
      else
        @delivery_method = DistributionPluginDeliveryMethod.create!(params[:delivery_method])
      end
    else
      @delivery_method = DistributionPluginDeliveryMethod.new(:node_id => params[:node_id])
    end
  end

  def edit
    @delivery_method = DistributionPluginDeliveryMethod.find_by_id(params[:id])
  end

  def destroy
    dm = DistributionPluginDeliveryMethod.find_by_id(params[:id])
    @delivery_method_id = dm.id
    dm.destroy if dm
    flash[:notice] = _('Delivery method removed from cycle')
  end
end
