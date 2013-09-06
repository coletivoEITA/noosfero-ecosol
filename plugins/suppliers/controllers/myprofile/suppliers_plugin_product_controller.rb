# workaround for plugins' scope problem
require_dependency 'suppliers_plugin/product_helper'

class SuppliersPluginProductController < MyProfileController

  helper SuppliersPlugin::ProductHelper

  def index
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:supplier_id]
    not_distributed_products

    @products = @node.products.unarchived.distributed.paginate({
      :per_page => 10, :page => params[:page],
      }.merge(search_scope.proxy_options))
    @all_products_count = @node.products.unarchived.distributed.count
    @product_categories = ProductCategory.find(:all)
    @new_product = SuppliersPlugin::DistributedProduct.new :profile => profile, :supplier => @supplier

    respond_to do |format|
      format.html
      format.js { render :partial => 'search' }
    end
  end

  def edit
    @product = SuppliersPlugin::DistributedProduct.find params[:id]
    @product.update_attributes params[:product]
  end

  def destroy
    @product = SuppliersPlugin::BaseProduct.find params[:id]
    if @product.nil?
      flash[:notice] = t('suppliers_plugin.controllers.myprofile.product_controller.the_product_was_not_r')
      false
    else
      @product.archive and flash[:notice] = t('suppliers_plugin.controllers.myprofile.product_controller.product_removed_succe')
    end
  end

  protected

  def not_distributed_products supplier_product_id = nil
    @not_distributed_products = @node.not_distributed_products @supplier unless !@supplier or @supplier.dummy? or supplier_product_id
  end

  def search_scope
    klass = SuppliersPlugin::BaseProduct
    scope = SuppliersPlugin::BaseProduct.scoped :conditions => []
    scope = scope.from_supplier_id(params[:supplier_id]) unless params[:supplier_id].blank?

    conditions = []
    conditions << {:available => params[:available]} unless params[:available].blank?
    unless params[:name].blank?
      name = ActiveSupport::Inflector.transliterate(params[:name]).strip.downcase
      conditions << ["LOWER(name) LIKE ?", "%#{name}%"]
    end
    conditions = [scope.proxy_options[:conditions], *conditions]

    scope.proxy_options[:conditions] = klass.merge_conditions *conditions

    scope
  end

end
