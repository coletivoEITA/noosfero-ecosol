# workaround for plugin class scope problem
require 'suppliers_plugin/product_helper'

class OrdersCyclePluginOrderController < OrdersPluginOrderController

  # FIXME: remove me when styles move from consumers_coop plugin
  include ConsumersCoopPlugin::ControllerHelper
  include OrdersCyclePlugin::TranslationHelper

  no_design_blocks
  before_filter :login_required, except: [:index]

  helper OrdersCyclePlugin::OrdersCycleDisplayHelper
  helper SuppliersPlugin::ProductHelper
  helper OrdersCyclePlugin::TranslationHelper

  def index
    @current_year = DateTime.now.year.to_s
    @year = (params[:year] || @current_year).to_s

    @years_with_cycles = profile.orders_cycles_without_order.years.collect &:year
    @years_with_cycles.unshift @current_year unless @years_with_cycles.include? @current_year

    @cycles = profile.orders_cycles.by_year @year
    @consumer = user
  end

  def new
    if user.blank?
      session[:notice] = t('orders_plugin.controllers.profile.consumer.please_login_first')
      redirect_to action: :index
      return
    end

    if not profile.members.include? user
      render_access_denied
    else
      @consumer = user
      @cycle = OrdersCyclePlugin::Cycle.find params[:cycle_id]
      @order = OrdersPlugin::Sale.new
      @order.profile = profile
      @order.consumer = @consumer
      @order.cycle = @cycle
      @order.save!
      redirect_to params.merge(action: :edit, id: @order.id)
    end
  end

  def edit
    return show_more if params[:page].present?
    return super if request.xhr?

    if cycle_id = params[:cycle_id]
      @cycle = OrdersCyclePlugin::Cycle.find_by_id cycle_id
      return render_not_found unless @cycle
      @consumer = user
    else
      return render_not_found unless @order
      @cycle = @order.cycle

      @consumer = @order.consumer
      @admin_edit = (user and user != @consumer)
      return render_access_denied if @admin_edit and not profile.admins.include? @consumer

      @consumer_orders = @cycle.sales.for_consumer @consumer
    end

    load_products_for_order
    @product_categories = @cycle.product_categories
    @consumer_orders = @cycle.sales.for_consumer @consumer
  end

  def cancel
    super
    redirect_to action: :index, cycle_id: @order.cycle.id
  end

  def remove
    super
    redirect_to action: :index, cycle_id: @order.cycle.id
  end

  def admin_new
    return redirect_to action: :index unless profile.has_admin? user

    @consumer = user
    @cycle = OrdersCyclePlugin::Cycle.find params[:cycle_id]
    @order = OrdersPlugin::Sale.create! cycle: @cycle, consumer: @consumer
    redirect_to action: :edit, id: @order.id, profile: profile.identifier
  end

  def filter
    if id = params[:id]
      @order = OrdersPlugin::Sale.find id rescue nil
      @cycle = @order.cycle
    else
      @cycle = OrdersCyclePlugin::Cycle.find params[:cycle_id]
      @order = OrdersPlugin::Sale.find params[:order_id] rescue nil
    end
    load_products_for_order

    render partial: 'filter', locals: {
      order: @order, cycle: @cycle,
      products_for_order: @products,
    }
  end

  def show_more
    filter
  end

  def render_delivery
    @order = profile.sales.find params[:id]
    @order.attributes = params[:order]
    @order.sync_supplier_delivery_data
    render partial: 'orders_plugin_order/delivery', locals: {order: @order, actor_name: :supplier}
  end

  def supplier_balloon
    @supplier = SuppliersPlugin::Supplier.find params[:id]
    render layout: false
  end
  def product_balloon
    @product = OrdersCyclePlugin::OfferedProduct.find params[:id]
    render layout: false
  end

  protected

  def load_products_for_order
    scope = @cycle.products_for_order
    page, per_page = params[:page].to_i, 20
    page = 1 if page < 1
    @products = SuppliersPlugin::BaseProduct.search_scope(scope, params).paginate page: page, per_page: per_page
  end

  extend ControllerInheritance::ClassMethods
  hmvc OrdersCyclePlugin

end
