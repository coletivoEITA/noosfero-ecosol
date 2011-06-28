class DistributionOrderController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def new
    params[:id] ||= 996332880
    order = DistributionOrder.create!(:order_session_id => params[:id])
    redirect_to :action => :edit, :id => order.id
  end

  def edit
    @order = DistributionOrder.find_by_id(params[:id])
    @session = @order.order_session
    @products = @session.products 
    @order_products = @order.ordered_products
  end

  def filter_products
    @products = @session.products.find_by_contents(query)
  end

  def close_order
    @order.close
  end
end
