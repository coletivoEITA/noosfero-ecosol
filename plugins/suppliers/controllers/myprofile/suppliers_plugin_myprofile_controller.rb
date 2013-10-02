# workaround for plugins' scope problem
require_dependency 'suppliers_plugin/display_helper'
SuppliersPlugin::SuppliersDisplayHelper = SuppliersPlugin::DisplayHelper

class SuppliersPluginMyprofileController < MyProfileController

  no_design_blocks
  before_filter :load_new, :only => [:index, :new]

  helper SuppliersPlugin::SuppliersDisplayHelper

  def index
    @suppliers = search_scope(profile.suppliers.except_self).paginate(:per_page => 10, :page => params[:page])
    @is_search = params[:name] or params[:active]

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
    @supplier.destroy
  end

  def enterprise_search
    @enterprises = find_by_contents(:enterprises, environment.enterprises, params[:query])[:results]
    @enterprises -= profile.suppliers.collect(&:profile)
  end

  def add_enterprise
    @enterprise = environment.enterprises.find params[:id]
    profile.suppliers.create! :profile => @enterprise
    self.index
  end

  protected

  def load_new
    @new_supplier = SuppliersPlugin::Supplier.new_dummy :consumer => profile
    @new_profile = @new_supplier.profile
  end

  def search_scope scope
    scope = scope.by_active(params[:active]) if params[:active].present?
    scope = scope.with_name(params[:name]) if params[:name].present?
    scope
  end
end
