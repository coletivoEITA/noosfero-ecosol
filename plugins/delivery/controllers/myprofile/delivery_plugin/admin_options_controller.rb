class DeliveryPlugin::AdminOptionsController < MyProfileController

  no_design_blocks

  before_filter :load_methods
  before_filter :load_owner
  protect 'edit_profile', :profile

  helper OrdersPlugin::FieldHelper

  def select
  end

  def new
    ids = params[:delivery_methods]
    dms = profile.delivery_methods.find ids
    (dms - @owner.delivery_methods).each do |dm|
      DeliveryPlugin::Option.create! owner_id: @owner.id, owner_type: @owner.class.name, delivery_method: dm
    end
  end

  def destroy
    @delivery_option = @owner.delivery_options.find params[:id]
    @delivery_option.destroy
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
