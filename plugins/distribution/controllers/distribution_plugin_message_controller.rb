class DistributionPluginMessageController < DistributionPluginMyprofileController
  no_design_blocks

  def new_to_consumer_for_order
    @order = DistributionPluginOrder.find params[:order_id]
    @consumer = @order.consumer
    if params[:commit]
      if params[:include_order]
        DistributionPlugin::Mailer.deliver_message_to_consumer_for_order @node, @order, params[:email][:subject], params[:email][:message]
      else
        DistributionPlugin::Mailer.deliver_message_to_consumer @node, @consumer, params[:email][:subject], params[:email][:message]
      end
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_consumer
    @consumer = DistributionPluginNode.find params[:consumer_id]
    if params[:commit]
      DistributionPlugin::Mailer.deliver_message_to_consumer @node, @consumer, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  def new_to_supplier
    @supplier = DistributionPluginSupplier.find params[:supplier_id]
    if params[:commit]
      DistributionPlugin::Mailer.deliver_message_to_supplier @node, @supplier, params[:email][:subject], params[:email][:message]
      page_reload
    else
      render :layout => false
    end
  end

  protected

  def page_reload
    session[:notice] = _('Message sent')
    respond_to do |format|
      format.js { render :partial => 'distribution_plugin_shared/pagereload' }
    end
  end

end
