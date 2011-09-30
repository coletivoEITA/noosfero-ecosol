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
    @suppliers = @node.supplier_nodes
    @product_categories = ProductCategory.find(:all)

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def new
    if params[:product][:supplier_id].blank?
      render :nothing => true
      return
    end

    @supplier = DistributionPluginNode.find params[:product][:supplier_id]
    @from_product = DistributionPluginProduct.find params[:from_product_id] if params[:from_product_id]
    if @supplier.dummy? or @from_product
      @product = DistributionPluginProduct.new :node => @node, :supplier => @supplier, :from_product => @from_product
      respond_to { |format| format.js { render :partial => 'edit', :locals => {:product => @product, :from_product => @from_product} } }
    else
      @not_distributed_products = @node.not_distributed_products @supplier
      respond_to { |format| format.js { render :partial => 'select_missing' } }
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
