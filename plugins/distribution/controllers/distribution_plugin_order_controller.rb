class DistributionPluginOrderController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  no_design_blocks
  layout false

  def index_received
    @node = DistributionPluginNode.find(params[:node_id])
    @orders = @node.orders_received
  end

  def index_sent
    if params[:node_id].nil?
      @node = DistributionPluginNode.find_by_profile_id(current_user.person.id)
    else
      @node = DistributionPluginNode.find(params[:node_id])
    end
    @orders = @node.orders_sent
  end

  def new
    order = DistributionPluginOrder.create!(:session_id => params[:id])
    respond_to do |format|
      format.html ( redirect_to :action => :edit, :id => order.id )
      format.js
    end
  end

  def edit
    @order = DistributionPluginOrder.find_by_id(params[:id])
    @session = @order.session
    @session_products = @session.products 
    @order_products = @order.ordered_products
    @product_categories = ProductCategory.find :all, :limit => 10
  end

  def filter_products
    @products = @session.products.find_by_contents(params[:query])
  end

  def close
    DistributionPluginOrder.update (params[:id], {:status => 'closed'})
    redirect_to :action => :index_sent
  end
end
