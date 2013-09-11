# workaround for plugins' scope problem
require_dependency 'suppliers_plugin/product_helper'

class SuppliersPluginProductController < MyProfileController

  no_design_blocks

  helper SuppliersPlugin::ProductHelper
  helper SuppliersPlugin::DisplayHelper

  def index
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:supplier_id] if params[:supplier_id].present?

    @products =           profile.products.unarchived.distributed.paginate({
      :per_page => 10, :page => params[:page], :order => 'products.name ASC'
      }.merge(search_scope.proxy_options))
    @all_products_count = profile.products.unarchived.distributed.count search_scope.proxy_options
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
    scope = klass.scoped :conditions => []
    scope = scope.from_supplier_id params[:supplier_id] if params[:supplier_id].present?

    conditions = []
    conditions << {:available => params[:available]} if params[:available].present?
    if params[:name].present?
      name = ActiveSupport::Inflector.transliterate(params[:name]).strip.downcase
      conditions << ["LOWER(products.name) LIKE ?", "%#{name}%"]
    end
    conditions = [scope.proxy_options[:conditions], *conditions]

    scope.proxy_options[:conditions] = klass.merge_conditions *conditions

    scope
  end

end
