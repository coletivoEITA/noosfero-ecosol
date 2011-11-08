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
    conditions = DistributionPluginDistributedProduct.send :merge_conditions, conditions

    @products = @node.products.unarchived.distributed.all :conditions => conditions, :group => (['supplier_id', 'id']+DistributionPluginProduct.new.attributes.keys).join(',')
    @all_products_count = @node.products.unarchived.distributed.count
    @product_categories = ProductCategory.find(:all)
    @new_product = DistributionPluginDistributedProduct.new :node => @node, :supplier_id => params[:supplier_id]

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def new
    @supplier = DistributionPluginSupplier.find_by_id params[:product][:supplier_id].to_i
    if params[:commit]
      #:supplier_product_id must be set first. it will when params follow the form order with ruby 1.9 ordered hashes
      @product = DistributionPluginDistributedProduct.new :node => @node, :supplier_product_id => params[:product].delete(:supplier_product_id)
      @product.update_attributes! params[:product]
    else
      @product = DistributionPluginDistributedProduct.new :node => @node, :supplier => @supplier
      @product.supplier_product_id = params[:product][:supplier_product_id] if @supplier.node != @node
      not_distributed_products(params[:product][:supplier_product_id])
      render :partial => 'edit', :locals => {:product => @product}
    end
  end

  def edit
    @product = DistributionPluginDistributedProduct.find params[:id]
    @product.update_attributes! params[:product]
    render :layout => false
  end

  def add_missing_products
    @supplier = DistributionPluginSupplier.find params[:product][:supplier_id]
    @node.add_supplier_products @supplier
    render :partial => 'distribution_plugin_shared/pagereload'
  end

  def session_edit
    @product = DistributionPluginSessionProduct.find params[:id]
    if request.xhr?
      @product.update_attributes! params[:product]
      respond_to do |format|
        format.js
      end
    end
  end

  def session_destroy
    @product = DistributionPluginSessionProduct.find params[:id]
    @product.destroy!
    flash[:notice] = _('Product removed from cycle')
  end

  protected

  def not_distributed_products(supplier_product_id = nil)
    @not_distributed_products = @node.not_distributed_products @supplier unless !@supplier or @supplier.dummy? or supplier_product_id
  end

end
