class NetworksPluginAdminController < AdminController

  include NetworksPlugin::TranslationHelper

  helper NetworksPlugin::TranslationHelper

  before_filter :load_networks, :only => [:index, :create]

  def index
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

  protected

  def load_networks
    @networks = environment.networks.visible
  end

end
