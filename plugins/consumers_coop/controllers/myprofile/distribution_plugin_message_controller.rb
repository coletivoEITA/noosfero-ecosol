class ConsumersCoopPluginMessageController < ConsumersCoopPluginMyprofileController

  no_design_blocks

  def new_to_consumer_for_order
    @order = OrdersPlugin::Order.find params[:order_id]
    @consumer = @order.consumer
    if params[:commit]
      if params[:include_order]
        ConsumersCoopPlugin::Mailer.deliver_message_to_consumer_for_order @node, @order, params[:email][:subject], params[:email][:message]
      else
        ConsumersCoopPlugin::Mailer.deliver_message_to_consumer @node, @consumer, params[:email][:subject], params[:email][:message]
      end
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_consumer
    @consumer = ConsumersCoopPlugin::Node.find params[:consumer_id]
    if params[:commit]
      ConsumersCoopPlugin::Mailer.deliver_message_to_consumer @node, @consumer, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_supplier
    @supplier = SuppliersPlugin::Supplier.find params[:supplier_id]
    if params[:commit]
      ConsumersCoopPlugin::Mailer.deliver_message_to_supplier @node, @supplier, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_admins
    @member = @user_node
    if params[:commit]
      ConsumersCoopPlugin::Mailer.deliver_message_to_admins @node, @member, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  protected

  def page_reload
    session[:notice] = t('orders_cycle_plugin.controllers.myprofile.message_controller.message_sent')
    respond_to do |format|
      format.js { render :partial => 'suppliers_plugin_shared/pagereload' }
    end
  end

end
