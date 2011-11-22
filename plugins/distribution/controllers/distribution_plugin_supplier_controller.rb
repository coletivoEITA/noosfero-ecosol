class DistributionPluginSupplierController < DistributionPluginMyprofileController
  no_design_blocks

  before_filter :set_admin_action, :only => [:index]
  before_filter :load_new, :only => [:index, :new]

  def index
    @suppliers = @node.suppliers - [@node.self_supplier]
  end

  def new
    @new_supplier.update_attributes! params[:supplier] #beautiful transactional save
  end

  def edit
    @supplier = DistributionPluginSupplier.find params[:id]
    @supplier.update_attributes! params[:supplier]
  end

  def destroy
    @supplier = DistributionPluginSupplier.find params[:id]
    @supplier.destroy
  end

  protected

  def load_new
    @new_supplier = DistributionPluginSupplier.new_from_consumer @node
    @new_supplier_node = @new_supplier.node
    @new_profile = @new_supplier_node.profile
  end

end
