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
      @network = self.environment.networks.build params[:network]
      @network.identifier = @network.name.to_slug
      @network.enabled = true
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
