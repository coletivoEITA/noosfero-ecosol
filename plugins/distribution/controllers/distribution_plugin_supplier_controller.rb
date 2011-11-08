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
    @new_profile = Enterprise.new :visible => false, :environment => profile.environment
    @new_profile.identifier = Digest::MD5.hexdigest(rand.to_s)
    @new_supplier_node = DistributionPluginNode.new :role => 'supplier', :profile => @new_profile
    @new_supplier = DistributionPluginSupplier.new :node => @new_supplier_node, :consumer => @node
  end

end
