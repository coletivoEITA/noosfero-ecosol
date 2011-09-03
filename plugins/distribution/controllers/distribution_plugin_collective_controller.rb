class DistributionPluginCollectiveController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:our_products]

  def index
    @node = DistributionPluginNode.find_by_profile_id(profile.id)
  end

  def our_products
    node = DistributionPluginNode.find_by_profile_id profile.id
    conditions = {}
    if !params[:active].nil?
        conditions[:active] = params["active"] unless params["active"] == ""
    end
    @products = DistributionPluginProduct.find_all_by_node_id(node.id, :conditions => conditions, :joins => :product)
    @products = @products.find_all {|p| p.supplier.id == params[:supplier].to_i} if !params[:supplier].nil? && params[:supplier] != ""
    @products = @products.find_all {|p| p.product.product_category_id == params[:product_category].to_i} if !params[:supplier].nil? && params[:product_category] != ""
    @suppliers = node.suppliers
    @product_categories = ProductCategory.find(:all)
    @params = params

    respond_to do |format|
        format.html 
        format.js {render :partial => "our_products_box", :object => @products }
    end
  end

  def suppliers
  end

  def members
  end

  def about
    redirect_to :action => "index", :profile => params[:profile]
  end

  protected

  def custom_contents
    [:header, :admin_sidebar]
  end

end
