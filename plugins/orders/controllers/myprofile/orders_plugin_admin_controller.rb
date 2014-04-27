# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPluginAdminController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks
  before_filter :set_admin

  helper OrdersPlugin::OrdersDisplayHelper

  def index
    @purchases_month = profile.purchases.latest.first.created_at.month rescue Date.today.month
    @purchases_year = profile.purchases.latest.first.created_at.year rescue Date.today.year
    @sales_month = profile.sales.latest.first.created_at.month rescue Date.today.month
    @sales_year = profile.sales.latest.first.created_at.year rescue Date.today.year

    @purchases = profile.purchases.latest.by_month(@purchases_month).by_year(@purchases_year).paginate(:per_page => 30, :page => params[:page])
    @sales = profile.sales.latest.by_month(@sales_month).by_year(@sales_year).paginate(:per_page => 30, :page => params[:page])
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

  protected

  def filter_methods
    ['sales', 'purchases']
  end

  def set_admin
    @admin = true
  end

end
