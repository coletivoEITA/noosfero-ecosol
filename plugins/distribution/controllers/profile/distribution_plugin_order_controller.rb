class DistributionPluginOrderController < DistributionPluginProfileController

  no_design_blocks

  before_filter :login_required, :except => [:index, :edit]
  before_filter :set_admin_action, :only => [:session_edit]

  helper DistributionPlugin::DistributionProductHelper

  def index
    @year = (params[:year] || DateTime.now.year).to_s
    @sessions = @node.sessions.by_year @year
    @consumer = @user_node
  end

  def new
    @consumer = @user_node
    @session = DistributionPluginSession.find params[:session_id]
    @order = DistributionPluginOrder.create! :session => @session, :consumer => @consumer
    redirect_to :action => :edit, :id => @order.id, :profile => profile.identifier
  end

  def admin_new
    @consumer = DistributionPluginNode.find params[:consumer_id]
    @session = DistributionPluginSession.find params[:session_id]
    @order = DistributionPluginOrder.create! :session => @session, :consumer => @consumer
    redirect_to :action => :edit, :id => @order.id, :profile => profile.identifier
  end

  def edit
    if session_id = params[:session_id]
      @session = DistributionPluginSession.find_by_id session_id
      return render_not_found unless @session
      @consumer = @user_node
    else
      @order = DistributionPluginOrder.find_by_id params[:id]
      return render_not_found unless @order
      @session = @order.session
      @consumer = @order.consumer
      @admin_edit = @user_node && @user_node != @consumer
    end
    @consumer_orders = @session.orders.for_consumer @consumer
  end

  def reopen
    @order = DistributionPluginOrder.find params[:id]
    raise "Cycle's orders period already ended" unless @order.session.orders?
    @order.update_attributes! :status => 'draft'

    redirect_to :action => :edit, :id => @order.id
  end

  def confirm
    params[:order] ||= {}

    @order = DistributionPluginOrder.find params[:id]
    raise "Cycle's orders period already ended" unless @order.session.orders?
    @order.update_attributes! params[:order].merge(:status => 'confirmed')

    DistributionPlugin::Mailer.deliver_order_confirmation @order, request.host_with_port
    session[:notice] = _('Order confirmed')
    redirect_to :action => :edit, :id => @order.id
  end

  def cancel
    @order = DistributionPluginOrder.find params[:id]
    @order.update_attributes! :status => 'cancelled'

    DistributionPlugin::Mailer.deliver_order_cancellation @order
    session[:notice] = _('Order cancelled')
    redirect_to :action => :index, :session_id => @order.session.id
  end

  def remove
    @order = DistributionPluginOrder.find params[:id]
    @order.destroy

    session[:notice] = _('Order removed')
    redirect_to :action => :index, :session_id => @order.session.id
  end

  def render_delivery
    @order = DistributionPluginOrder.find params[:id]
    @order.attributes = params[:order]
    render :partial => 'delivery', :layout => false, :locals => {:order => @order}
  end

  def session_edit
    @order = DistributionPluginOrder.find params[:id]

    if @order.session.orders?
      a = {}; @order.products.map{ |p| a[p.id] = p }
      b = {}; params[:order][:products].map do |key, attrs|
        p = DistributionPluginOrderedProduct.new attrs
        p.id = attrs[:id]
        b[p.id] = p
      end

      removed = a.values.map do |p|
        p if b[p.id].nil?
      end.compact
      changed = b.values.map do |p|
        pa = a[p.id]
        if pa and p.quantity_asked != pa.quantity_asked
          pa.quantity_asked = p.quantity_asked
          pa
        end
      end.compact

      changed.each{ |p| p.save! }
      removed.each{ |p| p.destroy }
    end

    if params[:warn_consumer]
      message = (params[:include_message] and !params[:message].blank?) ? params[:message] : nil
      DistributionPlugin::Mailer.deliver_order_change_notification @node, @order, changed, removed, message
    end

  end

  protected

end
