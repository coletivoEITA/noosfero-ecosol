class OrdersPluginAdminItemController < MyProfileController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersPlugin::DisplayHelper

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

  extend HMVC::ClassMethods
  hmvc OrdersPlugin, orders_context: OrdersPlugin

end
