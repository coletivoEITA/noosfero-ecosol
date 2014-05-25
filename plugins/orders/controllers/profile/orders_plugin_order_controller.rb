class OrdersPluginOrderController < ProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  before_filter :login_required, :except => [:index, :edit]
  before_filter :load_order, :except => [:new]
  before_filter :check_access, :only => [:confirm, :remove, :cancel]
  before_filter :set_actor_name

  helper OrdersPlugin::TranslationHelper
  helper OrdersPlugin::OrdersDisplayHelper

  def edit
    status = params[:order][:status]
    if status == 'ordered'
      if @order.items.size > 0
        @order.update_attributes! :status => status
        session[:notice] = t('orders_plugin.controllers.profile.consumer.order_confirmed')
      else
        session[:notice] = t('orders_plugin.controllers.profile.consumer.can_not_confirm_your_')
      end
    end
  end

  def reopen
    @order.update_attributes! :status => 'draft'
    render :action => :edit
  end

  def cancel
    @order.update_attributes! :status => 'cancelled'
    session[:notice] = t('orders_plugin.controllers.profile.consumer.order_cancelled')
    render :action => :edit
  end

  protected

  def load_order
    @order = OrdersPlugin::Sale.find_by_id params[:id]
    render_access_denied if @order.present? and not @order.may_view? user
  end

  def check_access access = 'view'
    unless @order.send "may_#{access}?", user
      session[:notice] = if user.blank? then t('orders_plugin.controllers.profile.consumer.login_first') else session[:notice] = t('orders_plugin.controllers.profile.consumer.you_are_not_the_owner') end
      redirect_to :action => :index
      false
    else
      true
    end
  end

  # default value, may be overwriten
  def set_actor_name
    @actor_name = :consumer
  end

  extend ControllerInheritance::ClassMethods
  hmvc OrdersPlugin

end
