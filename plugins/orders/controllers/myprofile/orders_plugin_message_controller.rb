class OrdersPluginMessageController < MyProfileController

  no_design_blocks

  helper OrdersPlugin::FieldHelper

  def new_to_consumer_for_order
    @order = OrdersPlugin::Order.find params[:order_id]
    @consumer = @order.consumer
    if params[:commit]
      if params[:include_order]
        OrdersPlugin::Mailer.deliver_message_to_consumer_for_order profile, @order, params[:email][:subject], params[:email][:message]
      else
        OrdersPlugin::Mailer.deliver_message_to_consumer profile, @consumer, params[:email][:subject], params[:email][:message]
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

end
