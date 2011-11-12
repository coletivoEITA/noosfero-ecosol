class DistributionPluginDeliveryOptionController < DistributionPluginMyprofileController

  no_design_blocks

  def select
    @session = DistributionPluginSession.find params[:session_id]
    @delivery_methods = @node.delivery_methods - @session.delivery_methods
    render :layout => false
  end

  def index
    @session = DistributionPluginSession.find params[:session_id]
  end

  def show
    @delivery_option = DistributionPluginSession.find params[:id]
  end

  def new
    @session = DistributionPluginSession.find params[:session_id]
    @delivery_method = params[:new_method].blank? ?
      DistributionPluginDeliveryMethod.find(params[:delivery_method_id]) :
      DistributionPluginDeliveryMethod.create!(params[:delivery_method].merge(:node => @session.node))
    @delivery_option = DistributionPluginDeliveryOption.new :session => @session, :delivery_method => @delivery_method
    @delivery_option.save! unless @session.new_record?
  end

  def destroy
    @delivery_method = DistributionPluginDeliveryOption.find params[:id]
    @delivery_method.destroy
  end

end
