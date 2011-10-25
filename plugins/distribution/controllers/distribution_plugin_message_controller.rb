class DistributionPluginMessageController < DistributionPluginMyprofileController
  no_design_blocks

  helper DistributionPlugin::DistributionDisplayHelper

  def new_to_consumer_for_order
    render :layout => false
  end

  def new_to_consumer
    render :layout => false
  end

  def new_to_supplier
    @supplier = DistributionPluginSupplier.find params[:supplier_id]
    if params[:commit]
      DistributionPlugin::Mailer.message_to_supplier @node, @supplier, params[:email][:subject], params[:email][:message]
      session[:notice] = _('Message sent')
      render :update do |page|
        page << "window.location.reload()"
      end
    else
      render :layout => false
    end
  end

end
