# workaround for plugins' scope problem
require_dependency 'suppliers_plugin/product_helper'

class SuppliersPluginProductController < MyProfileController

  helper SuppliersPlugin::ProductHelper

  def index
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:supplier_id]

    @products = profile.products.unarchived.distributed.paginate({
      :per_page => 10, :page => params[:page], :order => 'name ASC'
      }.merge(search_scope.proxy_options))
    @all_products_count = profile.products.unarchived.distributed.count
    @product_categories = ProductCategory.find(:all)
    @new_product = SuppliersPlugin::DistributedProduct.new :profile => profile, :supplier => @supplier

    respond_to do |format|
      format.html
      format.js { render :partial => 'suppliers_plugin_product/search' }
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
