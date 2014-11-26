class OrdersCyclePluginMessageController < OrdersPluginMessageController

  no_design_blocks

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  helper OrdersCyclePlugin::TranslationHelper
  helper OrdersPlugin::FieldHelper

  def new_to_supplier
    @supplier = SuppliersPlugin::Supplier.find params[:supplier_id]
    if params[:commit]
      OrdersCyclePlugin::Mailer.message_to_supplier(profile, @supplier, params[:email][:subject], params[:email][:message]).deliver
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_admins
    @member = user
    if params[:commit]
      OrdersCyclePlugin::Mailer.message_to_admins(profile, @member, params[:email][:subject], params[:email][:message]).deliver
      page_reload
    else
      render :layout => false
    end
  end

  protected

end
