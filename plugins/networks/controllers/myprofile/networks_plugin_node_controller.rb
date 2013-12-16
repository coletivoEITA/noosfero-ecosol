# workaround for plugins classes scope problem
require_dependency 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper

class NetworksPluginNodeController < MyProfileController

  include NetworksPlugin::TranslationHelper

  before_filter :load_node, :only => [:associate]

  helper NetworksPlugin::NetworksDisplayHelper

  def associate
    @new_node = NetworksPlugin::Node.new((params[:node] || {}).merge(:environment => environment, :parent => @node))

    if params[:commit]
      if @new_node.save
        render :partial => 'suppliers_plugin_shared/pagereload'
      else
        respond_to do |format|
          format.js
        end
      end
    else
      respond_to do |format|
        format.html{ render :layout => false }
      end
    end
  end

  def edit
    @node = NetworksPlugin::Node.find params[:id]

    if request.post?
      @node.update_attributes params[:profile_data]
      @node.home_page.update_attributes params[:home_page]
      session[:notice] = t('networks_plugin.controllers.node.edit')
      redirect_to :controller => :networks_plugin_network, :action => :show_structure, :node_id => @node.parent.id
    end
  end

  def destroy
    @node = NetworksPlugin::Node.find params[:id]
    @node.destroy

    @node.parent.reload
    @node = @node.parent
  end

  protected

  def load_node
    @network = profile
    @node = NetworksPlugin::Node.find_by_id(params[:id]) || @network
  end

end
