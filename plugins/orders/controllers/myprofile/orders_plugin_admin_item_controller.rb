class OrdersPluginAdminItemController < MyProfileController

  include OrdersPlugin::TranslationHelper

  protect 'edit_profile', :profile
  before_filter :set_admin

  helper OrdersPlugin::DisplayHelper

  def edit
    @consumer   = user
    @item       = OrdersPlugin::Item.find params[:id]
    @actor_name = params[:actor_name].to_sym

    @quantity = true
    ["accepted", "separated", "delivered"].each do |status|
      qtt = params[:item]["quantity_supplier_#{status}".to_sym]
      next if qtt.nil?
      if set_order_quantity(qtt || 1)
        params[:item]["quantity_supplier_#{status}".to_sym] = @quantity
      end
    end
    @item.update! params[:item] if @quantity

    serializer  = OrdersPlugin::OrderSerializer.new @item.order.reload, scope: self, actor_name: @actor_name
    render json: serializer.to_hash
  end

  def add_search
    @actor_name  = params[:actor_name].to_sym
    @order_class = if @actor_name == :supplier then :Sale else :Purchase end
    @order       = hmvc_context.const_get(@order_class).find params[:order_id]

    @query = params[:query].to_s
    @scope = @order.available_products.limit(10)
    @scope = @scope.joins(:from_product).from_products_in_stock if defined? StockPlugin
    @scope = @scope.includes :suppliers if defined? SuppliersPlugin
    # FIXME: do not work with cycles
    #@products = autocomplete(:catalog, @scope, @query, {per_page: 10, page: 1}, {})[:results]
    @products = @scope.where('products.name ILIKE ? OR products.name ILIKE ?', "#{@query}%", "% #{@query}%")

    render json: @products.map{ |p| OrdersPlugin::ProductSearchSerializer.new(p).to_hash }
  end

  def add
    @actor_name  = params[:actor_name].to_sym
    @order_class = if @actor_name == :supplier then :Sale else :Purchase end
    @order       = hmvc_context.const_get(@order_class).find params[:order_id]

    @product = @order.available_products.find params[:product_id]

    @item   = @order.items.find_by product_id: @product.id
    @item ||= @order.items.build product: @product
    @item.status_quantity = (@item.status_quantity || 0) + 1
    @item.save!

    serializer = OrdersPlugin::OrderSerializer.new @item.order.reload, scope: self, actor_name: @actor_name
    render json: {
      order:   serializer.to_hash,
      item_id: @item.id,
    }
  end

  protected

  def set_admin
    @admin = true
  end

  def set_order_quantity value
    @quantity = CurrencyFields.parse_localized_number value

    if @quantity > 0
      if defined? StockPlugin and @item.from_product.use_stock
        if @quantity > @item.from_product.stored
          @quantity = @item.from_product.stored
          @quantity_consumer_ordered_more_than_stored = @item.id || true
        end
      end
    end
    if @quantity <= 0 && @item
      @quantity = nil
      @item.destroy
    end

    @quantity
  end

  extend HMVC::ClassMethods
  hmvc OrdersPlugin

end
