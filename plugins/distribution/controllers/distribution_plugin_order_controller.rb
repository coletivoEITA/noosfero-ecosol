class DistributionPluginOrderController < DistributionPluginMyprofileController
  no_design_blocks

  def index
    @orders = @node.orders
  end

  def new
    consumer_node = DistributionPluginNode.find_by_profile_id current_user.person.id
    order = DistributionPluginOrder.create!(:session_id => params[:id], :consumer => consumer_node)
    respond_to do |format|
      format.html( redirect_to :action => :edit, :id => order.id, :profile => profile)
      format.js
    end
  end

  def edit
    @order = DistributionPluginOrder.find_by_id(params[:id])
    @session = @order.session
    @session_products = @session.products.all(:conditions => ['price > 0']).group_by {|sp| sp.product.product_category.name}
    @ordered_products = @order.products.all(:order => 'id asc')
    @product_categories = ProductCategory.find :all, :limit => 10
  end

  def filter_products
    @products = @session.products.find_by_contents(params[:query])
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
