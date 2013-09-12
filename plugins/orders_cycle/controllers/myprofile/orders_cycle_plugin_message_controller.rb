class OrdersCyclePluginMessageController < OrdersPluginMessageController

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  helper OrdersPlugin::FieldHelper

  no_design_blocks

  def new_to_supplier
    @supplier = SuppliersPlugin::Supplier.find params[:supplier_id]
    if params[:commit]
      OrdersCyclePlugin::Mailer.deliver_message_to_supplier profile, @supplier, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_admins
    @member = user
    if params[:commit]
      OrdersCyclePlugin::Mailer.deliver_message_to_admins profile, @member, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  protected

end
