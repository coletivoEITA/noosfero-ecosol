class DistributionPluginOrderController < DistributionPluginMyprofileController
  no_design_blocks

  def index
    @sessions = @node.sessions
    @consumer = @user_node
  end

  def new
    @consumer = DistributionPluginNode.find_by_profile_id current_user.person.id
    @session = DistributionPluginSession.find params[:session_id]
    @order = DistributionPluginOrder.create! :session => @session, :consumer => @consumer
    redirect_to :action => :edit, :id => @order.id, :profile => profile.identifier
  end

  def edit
    if params[:session_id]
      @session = DistributionPluginSession.find params[:session_id]
      @consumer = @user_node
    else
      @order = DistributionPluginOrder.find_by_id params[:id]
      @session = @order.session
      @consumer = @order.consumer
      @admin_edit = @user_node != @consumer
    end
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

    session[:notice] = _('Order confirmed')
    redirect_to :action => :edit, :id => @order.id
  end

  def cancel
    @order = DistributionPluginOrder.find params[:id]
    @order.update_attributes! :status => 'cancelled'

    session[:notice] = _('Order cancelled')
    redirect_to :action => :edit, :session_id => @order.session.id
  end

  def remove
    @order = DistributionPluginOrder.find params[:id]
    @order.destroy

    session[:notice] = _('Order removed')
    redirect_to :action => :edit, :session_id => @order.session.id
  end

  def render_delivery
    @order = DistributionPluginOrder.find params[:id]
    @delivery_method = DistributionPluginDeliveryMethod.find params[:delivery_method_id]
    render :partial => 'delivery', :layout => false, :locals => {:order => @order, :method => @delivery_method}
  end

  def session_edit
    @order = DistributionPluginOrder.find params[:id]
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

    if params[:warn_consumer] and !changed.blank? and !removed.blank?
      message = (params[:include_message] and !params[:message].blank?) ? params[:message] : nil
      DistributionPlugin::Mailer.deliver_order_change_notification @node, @order, changed, removed, message
    end

    changed.each{ |p| p.save! }
    removed.each{ |p| p.destroy }
  end

  protected

end
