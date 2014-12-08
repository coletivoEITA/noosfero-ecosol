class DeliveryPluginOptionController < MyProfileController

  no_design_blocks
  before_filter :load_methods
  before_filter :load_owner

  helper OrdersPlugin::FieldHelper
  helper SuppliersPlugin::JavascriptHelper

  def select
    render :layout => false
  end

  def new
    ids = params[:delivery_methods]
    dms = profile.delivery_methods.find ids
    (dms - @owner.delivery_methods).each do |dm|
      DeliveryPlugin::Option.create! :owner_id => @owner.id, :owner_type => @owner.class.name, :delivery_method => dm
    end
  end

  def destroy
    @delivery_option = @owner.delivery_options.find params[:id]
    @delivery_option.destroy
  end

  def method_new
    DeliveryPlugin::Method.create! params[:delivery_method].merge(:profile => profile, :delivery_type => 'pickup')
    # reset form for a new method
    @delivery_method = DeliveryPlugin::Method.new
  end

  def method_edit
    @delivery_method = profile.delivery_methods.find_by_id params[:id]
    if request.put?
      @delivery_method.update_attributes! params[:delivery_method].merge(:profile => profile, :delivery_type => 'pickup')
      # reset form for a new method
      @delivery_method = DeliveryPlugin::Method.new
    end
  end

  def method_destroy
    @delivery_methods = profile.delivery_methods.find params[:id]
    @delivery_methods.each{ |dm| dm.destroy }
    # render again
    @delivery_method = DeliveryPlugin::Method.new
  end

  protected

  def load_methods
    @delivery_methods = profile.delivery_methods
    @delivery_method = profile.delivery_methods.build
  end

  def load_owner
    @owner_id = params[:owner_id]
    @owner_type = params[:owner_type]
    @owner = @owner_type.constantize.find @owner_id
  end

end
