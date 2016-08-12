class OrdersPluginAdminItemController < MyProfileController

  include OrdersPlugin::TranslationHelper

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersPlugin::DisplayHelper

  def edit
    @consumer = user
    @item = OrdersPlugin::Item.find params[:id]
    @actor_name = params[:actor_name].to_sym
    @order = if @actor_name == :consumer then @item.purchase else @item.sale end

    @item.update! params[:item]
  end

  def add_search
    @actor_name  = params[:actor_name].to_sym
    @order_class = if @actor_name == :supplier then :Sale else :Purchase end
    @order       = hmvc_context.const_get(@order_class).find params[:order_id]

    @query = params[:query].to_s
    @scope = @order.available_products.limit(10)
    @scope = @scope.includes :suppliers if defined? SuppliersPlugin
    # FIXME: do not work with cycles
    #@products = autocomplete(:catalog, @scope, @query, {per_page: 10, page: 1}, {})[:results]
    @products = @scope.where('name ILIKE ? OR name ILIKE ?', "#{@query}%", "% #{@query}%")

    render json: @products.map{ |p| OrdersPlugin::ProductSearchSerializer.new(p).to_hash }
  end

  def add
    @actor_name  = params[:actor_name].to_sym
    @order_class = if @actor_name == :supplier then :Sale else :Purchase end
    @order       = hmvc_context.const_get(@order_class).find params[:order_id]

    @product = @order.available_products.find params[:product_id]

    @item   = @order.items.find_by product_id: @product.id
    @item ||= @order.items.build product: @product
    @item.next_status_quantity_set @actor_name, (@item.next_status_quantity(@actor_name) || @item.status_quantity || 0) + 1
    @item.save!
  end

  protected

  def set_admin
    @admin = true
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin

end
