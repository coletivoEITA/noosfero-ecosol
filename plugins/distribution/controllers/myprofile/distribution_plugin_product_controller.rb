class DistributionPluginProductController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:index]

  helper DistributionPlugin::DistributionProductHelper

  def index
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:supplier_id].to_i
    not_distributed_products

    @products = @node.products.unarchived.distributed.paginate :per_page => 10, :page => params[:page],
                 :conditions => search_filters,
                 :group => (['supplier_id', 'id']+DistributionPluginProduct.new.attributes.keys).join(',')
    @all_products_count = @node.products.unarchived.distributed.count
    @product_categories = ProductCategory.find(:all)
    @new_product = DistributionPluginDistributedProduct.new :node => @node, :supplier => @supplier

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def session_filter
    @session = DistributionPluginSession.find params[:session_id]
    @products = @session.products_for_order_by_supplier [search_filters]
    @order = DistributionPluginOrder.find_by_id params[:order_id]
    #@product_categories = ProductCategory.find(:all)

    render :partial => 'order_search', :locals => {
      :products_for_order_by_supplier => @products, :order => @order, :session => @session}
  end

  def new
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:product][:supplier_id].to_i
    if params[:commit]
      #:supplier_product_id must be set first. it will when params follow the form order with ruby 1.9 ordered hashes
      @product = DistributionPluginDistributedProduct.new :node => @node, :supplier_product_id => params[:product].delete(:supplier_product_id)
      begin
        @product.update_attributes params[:product]
      rescue
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
    @product.update_attributes params[:product]
  end

  def add_missing_products
    @supplier = SuppliersPlugin::Supplier.find params[:product][:supplier_id]
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
    flash[:notice] = t('distribution_plugin.controllers.myprofile.product_controller.product_removed_from_')
  end

  def destroy
    @product = DistributionPluginProduct.find params[:id]
    if @product.nil?
      flash[:notice] = t('distribution_plugin.controllers.myprofile.product_controller.the_product_was_not_r')
      false
    else
      @product.archive and flash[:notice] = t('distribution_plugin.controllers.myprofile.product_controller.product_removed_succe')
    end
  end


  protected

  def not_distributed_products supplier_product_id = nil
    @not_distributed_products = @node.not_distributed_products @supplier unless !@supplier or @supplier.dummy? or supplier_product_id
  end

  def search_filters
    base = DistributionPluginProduct.scoped :conditions => {:session_id => params[:session_id]}
    base = base.scoped :conditions => {:active_id => params[:active]} unless params[:active].blank?
    base = base.scoped :conditions => {:supplier_id => params[:supplier_id]} unless params[:supplier_id].blank?
    unless params[:name].blank?
      name = ActiveSupport::Inflector.transliterate params[:name].strip.downcase
      base = base.scoped :conditions => ["LOWER(name) LIKE ?", "%#{name}%"]
    end

    base.proxy_options[:conditions]
  end

end
