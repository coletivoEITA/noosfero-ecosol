class OrdersPluginMessageController < MyProfileController

  no_design_blocks

  #protect 'edit_profile', :profile

  helper OrdersPlugin::FieldHelper

  def new_to_consumer_for_order
    @order = profile.orders.find params[:order_id]
    if params[:commit]
      if params[:include_order]
        OrdersPlugin::Mailer.message_to_consumer_for_order(profile, @order, params[:email][:subject], params[:email][:message]).deliver
      else
        OrdersPlugin::Mailer.message_to_consumer(profile, @consumer, params[:email][:subject], params[:email][:message]).deliver
      end
      page_reload
    else
      render :layout => false
    end
  end

  protected

  def page_reload
    session[:notice] = t('orders_cycle_plugin.controllers.myprofile.message_controller.message_sent')
    respond_to do |format|
      format.js { render :partial => 'orders_plugin_shared/pagereload' }
    end
  end

  extend ControllerInheritance::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

end
