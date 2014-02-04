# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPluginAdminController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  helper OrdersPlugin::OrdersDisplayHelper

  def index
    @admin = true
  end

  def purchases
    @orders = profile.purchases
  end

  def sales
    @orders = profile.sales
  end

end
