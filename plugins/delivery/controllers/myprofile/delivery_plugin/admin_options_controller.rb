class DeliveryPlugin::AdminOptionsController < DeliveryPlugin::AdminMethodController

  protect 'edit_profile', :profile
  before_filter :load_context

  def select
  end

  def new
    ids = params[:method_ids]
    return super unless ids.present?

    load_owner
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

  def load_owner
    @owner_id = params[:owner_id]
    @owner_type = params[:owner_type]
    @owner = @owner_type.constantize.find @owner_id
  end

  def load_context
    @delivery_context = 'delivery_plugin/admin_options'
  end

end
