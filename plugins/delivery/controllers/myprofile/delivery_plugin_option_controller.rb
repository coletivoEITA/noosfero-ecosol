class DistributionPluginDeliveryOptionController < DistributionPluginMyprofileController

  no_design_blocks

  before_filter :load

  def select
    @session = DistributionPlugin::Session.find params[:session_id]
    render :layout => false
  end

  def index
    @session = DistributionPlugin::Session.find params[:session_id]
  end

  def show
    @delivery_option = DistributionPlugin::Session.find params[:id]
  end

  def new
    @session = DistributionPlugin::Session.find params[:session_id]
    @session.add_delivery_options = params[:session][:add_delivery_options]
    @session.save(false) # skip validations as needed for a new session
  end

  def destroy
    @delivery_option = @node.delivery_options.find params[:id]
    @session = @delivery_option.session
    @delivery_option.destroy
  end

  def method_destroy
    @delivery_method = @node.delivery_methods.find_by_id params[:id]
    @delivery_method.destroy
  end

  def method_new
    @delivery_method = DistributionPlugin::DeliveryMethod.create! params[:delivery_method].merge(:node => @node, :delivery_type => 'pickup')
  end

  def method_edit
    @delivery_method = @node.delivery_methods.find_by_id params[:id]
    if request.post?
      @delivery_method.update_attributes! params[:delivery_method].merge(:node => @node, :delivery_type => 'pickup')
      @delivery_method = DistributionPlugin::DeliveryMethod.new # reset form for a new method
    end
  end

  protected

  def load
    @delivery_methods = profile.delivery_methods
    @delivery_method = profile.delivery_methods.build
  end

end
