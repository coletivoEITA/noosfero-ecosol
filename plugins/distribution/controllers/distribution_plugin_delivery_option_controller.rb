class DistributionPluginDeliveryOptionController < DistributionPluginMyprofileController
  no_design_blocks

  def select
    @session = DistributionPluginSession.find_by_id(params[:session_id])
    @node = @session.node
    @delivery_methods = @node.delivery_methods - @session.delivery_methods
    render :layout => false
  end

  def index
    @session = DistributionPluginSession.find_by_id(params[:session_id])
    @node = @session.node
  end

  def show
    @delivery_option = DistributionPluginSession.find_by_id(params[:id])
  end

  def new
    @session = DistributionPluginSession.find_by_id(params[:session_id])
    if params[:new_method].nil?
      @delivery_method = DistributionPluginDeliveryMethod.find_by_id(params[:delivery_method_id])
    else
      @delivery_method = DistributionPluginDeliveryMethod.create!(params[:delivery_method].merge({:node => @session.node}))
    end
    @delivery_option = DistributionPluginDeliveryOption.create!(:session => @session, :delivery_method => @delivery_method)
  end

  def destroy
    dm = DistributionPluginDeliveryOption.find_by_id(params[:id])
    @delivery_option_id = dm.id
    dm.destroy if dm
    flash[:notice] = _('Delivery option removed from cycle')
  end
end
