class NetworksPluginNetworkController < MyProfileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:structure]

  helper NetworksPlugin::DisplayHelper

  def index
    redirect_to :structure
  end

  def structure
  end

  def join
    @enterprises = user.enterprises.visible.select{ |e| e.network != profile }

    if params[:enterprise_id]
      @enterprise = environment.enterprises.find params[:enterprise_id]
      if request.post?
        NetworksPlugin::AssociateEnterprise.create! :network => profile, :enterprise => @enterprise
        @request_sent = true
      end
    elsif @enterprises.size == 1
      @enterprise = @enterprises.first
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  protected

  def load_node
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:node_id]) || @network
  end

end
