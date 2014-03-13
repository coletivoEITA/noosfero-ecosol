# workaround for plugins' scope problem
require_dependency 'suppliers_plugin/display_helper'
SuppliersPlugin::SuppliersDisplayHelper = SuppliersPlugin::DisplayHelper

class SuppliersPluginProductController < MyProfileController

  no_design_blocks

  include SuppliersPlugin::TranslationHelper

  protect 'edit_profile', :profile

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::SuppliersDisplayHelper

  def index
    @supplier = SuppliersPlugin::Supplier.find_by_id params[:supplier_id] if params[:supplier_id].present?

    SuppliersPlugin::DistributedProduct.send :with_exclusive_scope do
      scope = profile.distributed_products.unarchived.from_products_joins
      @products = SuppliersPlugin::BaseProduct.search_scope(scope, params).paginate :per_page => 10, :page => params[:page], :order => 'from_products_products.name ASC'
      @products_count = SuppliersPlugin::BaseProduct.search_scope(scope, params).count
    end
    @product_categories = Product.product_categories_of @products
    @new_product = SuppliersPlugin::DistributedProduct.new :profile => profile, :supplier => @supplier
    @units = Unit.all

    respond_to do |format|
      format.html
      format.js { render :partial => 'suppliers_plugin_product/search' }
    end
  end

  def edit
    @product = SuppliersPlugin::DistributedProduct.find params[:id]
    @product.update_attributes params["product_#{@product.id}"]
  end

  def destroy
    @product = SuppliersPlugin::DistributedProduct.find params[:id]
    @product.destroy
    flash[:notice] = t('controllers.myprofile.product_controller.product_removed_succe')
  end

  def distribute_to_consumers
    params[:consumers] ||= {}

    @product = profile.products.find params[:id]
    @consumers = profile.consumers.find(params[:consumers].keys.to_a).collect &:profile
    to_add = @consumers - @product.consumers
    to_remove = @product.consumers - @consumers

    to_add.each{ |c| @product.distribute_to_consumer c }

    to_remove = to_remove.to_set
    @product.to_products.each{ |p| p.destroy if to_remove.include? p.profile }

    @product.reload
  end

  protected

end
