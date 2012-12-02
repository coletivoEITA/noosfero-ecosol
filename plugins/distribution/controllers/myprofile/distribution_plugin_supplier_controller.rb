class DistributionPluginSupplierController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:index]
  before_filter :load_new, :only => [:index, :new]

  def index
    params['name'] = "" if params['name'].blank?
    @suppliers = @node.suppliers.with_name(params['name']).paginate(:per_page => 10, :page => params["page"])

    respond_to do |format|
      format.html
      format.js { render :partial => 'suppliers_list', :locals => {:suppliers => @suppliers}}
    end
  end

  def new
    @new_supplier.update_attributes! params[:supplier] #beautiful transactional save
    session[:notice] = _('Supplier created')
  end

  def edit
    @supplier = DistributionPluginSupplier.find params[:id]
    @supplier.update_attributes! params[:supplier]
  end

  def destroy
    @supplier = DistributionPluginSupplier.find params[:id]
    @supplier.destroy!
  end

  protected

  def load_new
    @new_supplier = DistributionPluginSupplier.new_dummy :consumer => @node
    @new_supplier_node = @new_supplier.node
    @new_profile = @new_supplier_node.profile
  end

end
