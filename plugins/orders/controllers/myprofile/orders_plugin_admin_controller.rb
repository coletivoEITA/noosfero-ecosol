# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPluginAdminController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  helper OrdersPlugin::OrdersDisplayHelper

  def index
    @admin = true

    @purchases_month = profile.purchases.latest.first.created_at.month rescue Date.today.month
    @purchases_year = profile.purchases.latest.first.created_at.year rescue Date.today.year
    @sales_month = profile.sales.latest.first.created_at.month rescue Date.today.month
    @sales_year = profile.sales.latest.first.created_at.year rescue Date.today.year

    @purchases = profile.purchases.latest.by_month(@purchases_month).by_year(@purchases_year)
    @sales = profile.sales.latest.by_month(@sales_month).by_year(@sales_year)
  end

  def filter
    @method = params[:orders_method]
    raise unless self.filter_methods.include? @method

    @actor_name = params[:actor_name]

    # default value may be override
    @scope ||= profile
    @scope = @scope.send @method
    @orders = OrdersPlugin::Order.search_scope @scope, params

    render :layout => false
  end

  def edit
    @order = OrdersPlugin::Order.find params[:id]
    #return unless check_access 'edit'

    if @order.cycle.orders?
      a = {}; @order.items.map{ |p| a[p.id] = p }
      b = {}; params[:order][:items].map do |key, attrs|
        p = OrdersPlugin::Item.new attrs
        p.id = attrs[:id]
        b[p.id] = p
      end

      removed = a.values.map do |p|
        p if b[p.id].nil?
      end.compact
      changed = b.values.map do |p|
        pa = a[p.id]
        if pa and p.quantity_consumer_asked != pa.quantity_consumer_asked
          pa.quantity_consumer_asked = p.quantity_consumer_asked
          pa
        end
      end.compact

      changed.each{ |p| p.save! }
      removed.each{ |p| p.destroy }
    end

    if params[:warn_consumer]
      message = (params[:include_message] and !params[:message].blank?) ? params[:message] : nil
      OrdersCyclePlugin::Mailer.deliver_order_change_notification profile, @order, changed, removed, message
    end

  end

  protected

  def filter_methods
    ['sales', 'purchases']
  end

end
