class DistributionPluginProductController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:index]

  helper DistributionPlugin::DistributionProductHelper

  def index
    @supplier = DistributionPluginSupplier.find_by_id params[:supplier_id].to_i
    not_distributed_products

    conditions = []
    conditions += ['active = ?', params["active"]] unless params["active"].blank?
    conditions += ['supplier_id = ?', params["supplier_id"]] unless params["supplier_id"].blank?
    conditions += ['LOWER(name) LIKE ?', '%'+params["name"]+'%'] unless params["name"].blank?
    conditions = DistributionPluginProduct.send :merge_conditions, conditions

    @products = @node.products.distributed.all :conditions => conditions, :group => (['supplier_id', 'id']+DistributionPluginProduct.new.attributes.keys).join(',')
    @all_products_count = @node.products.distributed.count
    @product_categories = ProductCategory.find(:all)
    @new_product = DistributionPluginProduct.new :node => @node, :supplier_id => params[:supplier_id]

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def new
    @supplier = DistributionPluginSupplier.find_by_id params[:product][:supplier_id].to_i
    if params[:commit]
      #:supplier_product_id must be set first. it will when params follow the form order with ruby 1.9 ordered hashes
      @product = DistributionPluginProduct.new :node => @node, :supplier_product_id => params[:product].delete(:supplier_product_id)
      @product.update_attributes! params[:product]
    else
      @product = DistributionPluginProduct.new :node => @node, :supplier => @supplier, :supplier_product_id => params[:product][:supplier_product_id]
      not_distributed_products(params[:product][:supplier_product_id])
      render :partial => 'edit', :locals => {:product => @product}, :layout => false
    end
  end

  def edit
    @product = DistributionPluginProduct.find params[:id]
    @product.update_attributes! params[:product]
    render :layout => false
  end

  def session_edit
    @product = DistributionPluginProduct.find params[:id]
    if request.post?
      @product.update_attributes! params[:product]
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

  protected

  def not_distributed_products(supplier_product_id = nil)
    @not_distributed_products = @node.not_distributed_products @supplier unless !@supplier or @supplier.dummy? or supplier_product_id
  end

end
