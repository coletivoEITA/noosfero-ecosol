class NetworksPluginAdminController < AdminController

  def index
    @networks = environment.networks
  end

end
