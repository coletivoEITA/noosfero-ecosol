class OrdersPluginConsumerController < ProfileController

  no_design_blocks

  before_filter :login_required, :except => [:index, :edit]
  before_filter :load_order, :except => [:new]

  def confirm
    params[:order] ||= {}

    if @order.products.size > 0
      @order.update_attributes! params[:order].merge(:status => 'confirmed')
      DistributionPlugin::Mailer.deliver_order_confirmation @order, request.host_with_port
      session[:notice] = t('orders_plugin.controllers.profile.consumer.order_confirmed')
    else
      session[:notice] = t('orders_plugin.controllers.profile.consumer.can_not_confirm_your_')
    end

    redirect_to :action => :edit, :id => @order.id
  end

  def cancel
    @order = OrdersPlugin::Order.find params[:id]
    if @order.consumer != user and not profile.has_admin? user
      if user.nil?
        session[:notice] = t('orders_plugin.controllers.profile.consumer.login_first')
      else
        session[:notice] = t('orders_plugin.controllers.profile.consumer.you_are_not_the_owner')
      end
      redirect_to :action => :index
      return
    end
    @order.update_attributes! :status => 'cancelled'

    DistributionPlugin::Mailer.deliver_order_cancellation @order
    session[:notice] = t('orders_plugin.controllers.profile.consumer.order_cancelled')
    redirect_to :action => :index, :session_id => @order.session.id
  end

  def remove
    @order = OrdersPlugin::Order.find params[:id]
    if @order.consumer != user and not profile.has_admin? user
      if user.nil?
        session[:notice] = t('orders_plugin.controllers.profile.consumer.login_first')
      else
        session[:notice] = t('orders_plugin.controllers.profile.consumer.you_are_not_the_owner')
      end
      redirect_to :action => :index
      return
    end
    @order.destroy

    session[:notice] = t('orders_plugin.controllers.profile.consumer.order_removed')
    redirect_to :action => :index, :session_id => @order.session.id
  end

  protected

  def load_order
    @order = OrdersPlugin::Order.find_by_id params[:id]
    render_access_denied if @order and @order.consumer != user
  end

end
