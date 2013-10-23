# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginNetworkController < MyProfileController

  helper NetworksPlugin::NetworksDisplayHelper
  include NetworksPlugin::TranslationHelper

  def index
    redirect_to :show_structure
  end

  def show_structure
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:node_id]) || @network

    @nodes = @node.as_parent_relations.all.collect(&:child)
    @suppliers = @node.suppliers.except_self
  end

  protected

end
