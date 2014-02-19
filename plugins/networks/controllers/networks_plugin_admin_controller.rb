class NetworksPluginAdminController < AdminController

  include NetworksPlugin::TranslationHelper

  helper NetworksPlugin::TranslationHelper

  def index
    @networks = environment.networks.visible
    @network = NetworksPlugin::Network.new
  end

  def admin
    redirect_to :action => :index
  end

  def create
    if request.post?
      @network = NetworksPlugin::Network.new params[:network].merge(:environment => environment)
      @network.identifier = @network.name.to_slug
      if @network.save
        @network.add_admin user
        redirect_to :action => :index
      else
        render :action => :index
      end
    end
  end

end
