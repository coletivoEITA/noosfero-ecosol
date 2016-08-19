class SuppliersPlugin::ProductController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  no_design_blocks

  protect 'edit_profile', :profile

  serialization_scope :view_context

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  def index
    filter
    respond_to do |format|
      format.html{ render template: 'suppliers_plugin/product/index' }
      format.js{ render partial: 'suppliers_plugin/product/search' }
    end
  end

  def search
    filter
    if params[:page].present?
      render partial: 'suppliers_plugin/product/results'
    else
      render partial: 'suppliers_plugin/product/search'
    end
  end

  def add

  end

  def edit
    @product = profile.products.supplied.find params[:id]
    @product.update params["product_#{@product.id}"]
  end

  def import
    if params[:csv].present?
      if params[:remove_all_suppliers] == 'true'
        profile.suppliers.except_self.find_each(batch_size: 20){ |s| s.delay.destroy }
      end
      SuppliersPlugin::Import.delay.products profile, params[:csv].read

      @notice = t'controllers.product.import_in_progress'
      respond_to{ |format| format.js{ render layout: false } }
    else
      respond_to{ |format| format.html{ render layout: false } }
    end
  end

  def destroy
    @product = SuppliersPlugin::DistributedProduct.find params[:id]
    @product.destroy
    flash[:notice] = t('controllers.myprofile.product_controller.product_removed_succe')
  end

  def distribute_to_consumers
    params[:consumers] ||= {}

    @product = profile.products.find params[:id]
    @consumers = profile.consumers.find(params[:consumers].keys.to_a).collect(&:profile)
    to_add = @consumers - @product.consumers
    to_remove = @product.consumers - @consumers

    to_add.each{ |c| @product.distribute_to_consumer c }

    to_remove = to_remove.to_set
    @product.to_products.each{ |p| p.destroy if to_remove.include? p.profile }

    @product.reload
  end

  protected

  def filter
  end

  extend HMVC::ClassMethods
  hmvc SuppliersPlugin

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

end
