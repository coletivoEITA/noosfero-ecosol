class DistributionPluginProductController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:index]

  helper DistributionPlugin::DistributionProductHelper

  def index
    @supplier = DistributionPluginSupplier.find_by_id params[:supplier_id].to_i
    not_distributed_products

    conditions = ['', []]
     if not params["active"].blank?
       conditions = ['active = ?', [params["active"]]]
     end
     if not params["supplier_id"].blank?
       conditions[0] += ' AND ' unless conditions[0].blank?
       conditions[0] += 'supplier_id = ?'
       conditions[1] += [params["supplier_id"]]
     end
     if not params['name'].blank?
       conditions[0] += ' AND ' unless conditions[0].blank?
       conditions[0] += 'LOWER(name) LIKE ?'
       conditions[1] += ['%'+params["name"]+'%']
     end
    conditions = DistributionPluginDistributedProduct.send :merge_conditions, conditions.flatten

    @products = @node.products.unarchived.distributed.all :conditions => conditions, :group => (['supplier_id', 'id']+DistributionPluginProduct.new.attributes.keys).join(',')
    @all_products_count = @node.products.unarchived.distributed.count
    @product_categories = ProductCategory.find(:all)
    @new_product = DistributionPluginDistributedProduct.new :node => @node, :supplier => @supplier

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def filter_products
    conditions = ['', []]
    if not params["active"].blank?
      conditions = ['active = ?', [params["active"]]]
    end
    if not params["supplier_id"].blank?
      conditions[0] += ' AND ' unless conditions[0].blank?
      conditions[0] += 'supplier_id = ?'
      conditions[1] += [params["supplier_id"]]
    end
    if not params['name'].blank?
      conditions[0] += ' AND ' unless conditions[0].blank?
      conditions[0] += 'LOWER(name) LIKE ?'
      conditions[1] += ['%'+params["name"].downcase+'%']
    end
    if not params["session_id"].blank?
      conditions[0] += ' AND ' unless conditions[0].blank?
      conditions[0] += 'session_id = ?'
      conditions[1] += [params["session_id"]]
    end
    conditions = DistributionPluginSessionProduct.send :merge_conditions, conditions.flatten
    logger.debug conditions
    session = DistributionPluginSession.find params['session_id']
    @products = session.products_for_order_by_supplier conditions
    @order = DistributionPluginOrder.find_by_id params[:order_id]
    #@product_categories = ProductCategory.find(:all)

    render :partial => 'order_search', :locals => {
      :products_for_order_by_supplier => @products, :order => @order}
  end

  def new
    @supplier = DistributionPluginSupplier.find_by_id params[:product][:supplier_id].to_i
    if params[:commit]
      begin
        #:supplier_product_id must be set first. it will when params follow the form order with ruby 1.9 ordered hashes
        @product = DistributionPluginDistributedProduct.new :node => @node, :supplier_product_id => params[:product].delete(:supplier_product_id)
        @success = @product.update_attributes params[:product]
        if not @success
          render :partial => 'missing_field'
        end
      end
    else
      if @supplier
        @product = DistributionPluginDistributedProduct.new :node => @node, :supplier => @supplier
        @product.supplier_product_id = params[:product][:supplier_product_id] if @supplier.node != @node
        not_distributed_products(params[:product][:supplier_product_id])
      end
      render :partial => 'edit', :locals => {:product => @product}
    end
  end

  def edit
    @product = DistributionPluginDistributedProduct.find params[:id]
    @success = @product.update_attributes params[:product]
    if not @success
      render :partial => 'missing_field'
    end
    render :layout => false
  end

  def add_missing_products
    @supplier = DistributionPluginSupplier.find params[:product][:supplier_id]
    @node.add_supplier_products @supplier
    render :partial => 'distribution_plugin_shared/pagereload'
  end

  def search_category
    @categories = ProductCategory.name_like(params[:q]).all :limit => 5
    respond_to do |format|
      format.js do
        render :json => @categories.map { |c| DistributionPluginDistributedProduct.json_for_category(c) }
      end
    end
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
