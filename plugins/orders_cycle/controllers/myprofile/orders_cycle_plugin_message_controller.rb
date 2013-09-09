class OrdersCyclePluginMessageController < MyProfileController

  no_design_blocks

  def new_to_consumer_for_order
    @order = OrdersPlugin::Order.find params[:order_id]
    @consumer = @order.consumer
    if params[:commit]
      if params[:include_order]
        ConsumersCoopPlugin::Mailer.deliver_message_to_consumer_for_order profile, @order, params[:email][:subject], params[:email][:message]
      else
        ConsumersCoopPlugin::Mailer.deliver_message_to_consumer profile, @consumer, params[:email][:subject], params[:email][:message]
      end
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_consumer
    @consumer = Profile.find params[:consumer_id]
    if params[:commit]
      ConsumersCoopPlugin::Mailer.deliver_message_to_consumer profile, @consumer, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_supplier
    @supplier = SuppliersPlugin::Supplier.find params[:supplier_id]
    if params[:commit]
      ConsumersCoopPlugin::Mailer.deliver_message_to_supplier profile, @supplier, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_admins
    @member = user
    if params[:commit]
      ConsumersCoopPlugin::Mailer.deliver_message_to_admins profile, @member, params[:email][:subject], params[:email][:message]
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
