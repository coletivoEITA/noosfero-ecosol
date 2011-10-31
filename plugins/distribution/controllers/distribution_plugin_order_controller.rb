class DistributionPluginOrderController < DistributionPluginMyprofileController
  no_design_blocks

  def index
    @orders = @node.orders
  end

  def new
    @consumer = DistributionPluginNode.find_by_profile_id current_user.person.id
    @session = DistributionPluginSession.find params[:session_id]
    @order = DistributionPluginOrder.create! :session => @session, :consumer => @consumer
    redirect_to :action => :edit, :id => @order.id, :profile => profile.identifier
  end

  def edit
    @order = DistributionPluginOrder.find params[:id]
    @session = @order.session
    @session_products = @session.products.all(:conditions => ['price > 0']).group_by{ |sp| sp.product.product_category.name }
    @product_categories = ProductCategory.find :all, :limit => 10
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

  def filter_products
    @products = @session.products.find_by_contents params[:query]
  end

  def confirm
    @order = DistributionPluginOrder.find params[:id]
    @order.status = 'confirmed'
    redirect_to :action => :index
  end

  def remove
    @order = DistributionPluginOrder.find params[:id]
    @order.destroy
    redirect_to :action => :index
  end

end
