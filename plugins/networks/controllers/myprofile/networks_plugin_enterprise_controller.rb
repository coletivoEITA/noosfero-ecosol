class NetworksPluginEnterpriseController < MyProfileController

  def add
    @enterprise = environment.enterprises.find params[:enterprise_id]
    @supplier = SuppliersPlugin::Supplier.new
    @supplier.consumer = profile
    @supplier.profile = @enterprise

    if @supplier.save!
      flash[:notice] = "Entidade adicionada com sucesso a rede."
    end
    redirect_to :controller => :networks_plugin_network, :action => :show_structure
  end

  protected

end
