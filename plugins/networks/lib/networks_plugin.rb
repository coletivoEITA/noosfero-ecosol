require_dependency "#{File.dirname __FILE__}/ext/environment"
require_dependency "#{File.dirname __FILE__}/ext/enterprise"
require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/organization"

require_dependency "#{File.dirname __FILE__}/ext/sub_organizations_plugin/relation"

class NetworksPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('networks_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('networks_plugin.lib.plugin.description')
  end

  def js_files
    ['networks'].map{ |j| "javascripts/#{j}" }
  end

  def stylesheet?
    true
  end

  def control_panel_buttons
    if context.profile.node?
      {:title => I18n.t('networks_plugin.views.control_panel.structure'), :icon => 'networks-manage-structure', :url => {:controller => :networks_plugin_network, :action => :structure}}
    end
  end

  ProfileEditorFilter = proc do
    if profile.network_node?
      redirect_to :controller => :networks_plugin_node, :profile => profile.network.identifier, :action => :edit, :id => profile.id
    end
  end
  def profile_editor_controller_filters
    [
      {:type => 'before_filter', :method_name => 'networks_profile_editor',
       :options => {:only => [:edit]}, :block => ProfileEditorFilter},
    ]
  end

  def profile_editor_extras
    profile = context.profile
    return unless profile.enterprise?
    lambda do
      extend NetworksPlugin::TranslationHelper
      render 'networks_plugin_profile_editor/network_participation'
    end
  end

  def article_toolbar_actions article
    return unless article.profile.network?
    lambda do
      extend NetworksPlugin::TranslationHelper
      render 'networks_plugin_content_viewer/toolbar_actions', :article => article
    end
  end

  protected

  SearchFilter = proc do
    return unless params[:action] == 'networks'
  end

end

# workaround for plugins classes scope problem
require 'networks_plugin/display_helper'
NetworksPlugin::NetworksDisplayHelper = NetworksPlugin::DisplayHelper
require 'networks_plugin/search_helper'
NetworksPlugin::NetworksSearchHelper = NetworksPlugin::SearchHelper

