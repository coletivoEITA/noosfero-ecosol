# workaround for plugins' scope problem
require_dependency 'suppliers_plugin/display_helper'
SuppliersPlugin::SuppliersDisplayHelper = SuppliersPlugin::DisplayHelper

class SuppliersPluginMyprofileController < MyProfileController

  no_design_blocks
  before_filter :load_new, :only => [:index, :new]

  helper SuppliersPlugin::SuppliersDisplayHelper

  def index
    params['name'] = "" if params['name'].blank?
    if params['active'].blank?
      @suppliers = profile.suppliers.with_name(params['name']).paginate(:per_page => 10, :page => params["page"])
    else
      @suppliers = profile.suppliers.by_active(params['active']).with_name(params['name']).paginate(:per_page => 10, :page => params["page"])
    end

    respond_to do |format|
      format.html
      format.js { render :partial => 'suppliers_plugin_myprofile/suppliers_list', :locals => {:suppliers => @suppliers}}
    end
  end

  def new
    @new_supplier.update_attributes! params[:supplier] #beautiful transactional save
    session[:notice] = t('suppliers_plugin.controllers.myprofile.supplier_created')
  end

  def edit
    @supplier = SuppliersPlugin::Supplier.find params[:id]
    @supplier.update_attributes! params[:supplier]
  end

  def margin_change
    if params[:commit]
      profile.margin_percentage = params[:profile_data][:margin_percentage]
      profile.save
      profile.supplier_products_default_margins if params[:apply_to_all]

      render :partial => 'suppliers_plugin_shared/pagereload'
    else
      render :layout => false
    end
  end

  def toggle_active
    @supplier = SuppliersPlugin::Supplier.find params[:id]
    @supplier.toggle! :active
  end

  def destroy
    @supplier = SuppliersPlugin::Supplier.find params[:id]
    @supplier.destroy!
  end

  protected

  def load_new
    @new_supplier = SuppliersPlugin::Supplier.new_dummy :consumer => user
    @new_profile = @new_supplier.profile
  end

end
