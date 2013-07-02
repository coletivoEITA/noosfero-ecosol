class SuppliersPluginMyprofileController < MyProfileController

  helper SuppliersPlugin::SuppliersDisplayHelper

  before_filter :load_new, :only => [:index, :new]

  def index
    params['name'] = "" if params['name'].blank?
    @suppliers = profile.suppliers.with_name(params['name']).paginate(:per_page => 10, :page => params["page"])

    respond_to do |format|
      format.html
      format.js { render :partial => 'suppliers_list', :locals => {:suppliers => @suppliers}}
    end
  end

  def new
    @new_supplier.update_attributes! params[:supplier] #beautiful transactional save
    session[:notice] = t('distribution_plugin.controllers.myprofile.supplier_controller.supplier_created')
  end

  def edit
    @supplier = SuppliersPlugin::Supplier.find params[:id]
    @supplier.update_attributes! params[:supplier]
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
