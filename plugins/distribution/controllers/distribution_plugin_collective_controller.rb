class DistributionPluginCollectiveController < DistributionPluginMyprofileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  no_design_blocks

  def index
    @node = DistributionPluginNode.find_by_profile_id(profile.id)
  end

  def our_products
    node = DistributionPluginNode.find_by_profile_id profile.id
    conditions = {}
    if !params[:active].nil?
        conditions[:active] = params["active"] unless params["active"] == ""
        conditions[:node_id] = params[:supplier] unless params[:supplier] == ""
        conditions["product.product_category_id = ?"] = params[:product_category] unless params[:product_category] == ""
    else
        conditions = []
    end
    @products = DistributionPluginProduct.find_all_by_node_id(node.id, :conditions => conditions, :joins => :product)
    @suppliers = node.suppliers
    @product_categories = ProductCategory.find(:all)
    @params = params

    respond_to do |format|
        format.html {render :layout => false}
        format.js {render :partial => "our_products_box", :object => @products }
    end
  end

  def about
    redirect_to :action => "index", :profile => params[:profile]
  end
end
