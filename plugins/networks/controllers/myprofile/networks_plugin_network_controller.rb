# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginNetworkController < MyProfileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:show_structure]

  helper NetworksPlugin::NetworksDisplayHelper

  def index
    redirect_to :show_structure
  end

  def show_structure
  end

  protected

  def load_node
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:node_id]) || @network
  end

end
