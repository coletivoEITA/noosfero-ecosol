class DistributionPluginProductController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:index]

  helper DistributionPlugin::SessionHelper
  helper DistributionPlugin::DistributionDisplayHelper

  def index
    conditions = []
    conditions.add_condition(['active = ?', params["active"]]) unless params["active"].blank?
    conditions.add_condition(['supplier_id = ?', params["supplier"]]) unless params["supplier"].blank?
    conditions.add_condition(['LOWER(name) LIKE ?', '%'+params["name"]+'%']) unless params["name"].blank?
    @products = @node.products.distributed.all :conditions => conditions, :order => 'id asc'
    @all_products_count = @node.products.distributed.count
    @suppliers = @node.suppliers
    @product_categories = ProductCategory.find(:all)

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def edit
    @product = DistributionPluginProduct.find params[:id]
    @product.update_attributes params[:product]
    render :layout => false
  end

  def session_edit
    @product = DistributionPluginProduct.find params[:id]
    if request.post?
      @product.update_attributes(params[:product])
      @product.save!
    end
    if request.xhr?
      render :partial => 'session_edit', :locals => {:p => @product}, :layout => false
    end
  end

  def session_destroy
    @product = DistributionPluginProduct.find params[:id]
    raise 'Product not found' if @product
    @product_id = @product.id
    @product.destroy
    flash[:notice] = _('Product removed from session')
  end

end
