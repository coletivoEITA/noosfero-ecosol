# workaround for plugins' scope problem
require 'networks_plugin/search_helper'
NetworksPlugin::NetworksSearchHelper = NetworksPlugin::SearchHelper

class NetworksPluginSearchController < SearchController

  # FIXME: should be necessary again
  no_design_blocks

  include NetworksPlugin::TranslationHelper

  helper NetworksPlugin::TranslationHelper
  helper NetworksPlugin::NetworksSearchHelper

  def networks
    @titles[:networks] = _('Networks')
    @scope = @environment.networks.public
    full_text_search
  end

  protected

  include ControllerInheritance
  replace_url_for self.superclass => self

end
