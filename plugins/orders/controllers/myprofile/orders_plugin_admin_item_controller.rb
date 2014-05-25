# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

class OrdersPluginAdminItemController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks
  before_filter :set_admin

  helper OrdersPlugin::OrdersDisplayHelper

  def edit
    @consumer = user
    @item = OrdersPlugin::Item.find params[:id]
    @actor_name = params[:actor_name].to_sym
    @order = if @actor_name == :consumer then @item.purchase else @item.sale end

    @item.update_attributes! params[:item]
  end

  protected

  def set_admin
    @admin = true
  end

  extend ControllerInheritance::ClassMethods
  hmvc OrdersPlugin

end
