class NetworksPluginSearchController < SearchController

  # FIXME: should be necessary again, as done on superclass
  no_design_blocks

  include NetworksPlugin::TranslationHelper

  helper NetworksPlugin::TranslationHelper
  helper NetworksPlugin::SearchHelper

  def index
    redirect_to :controller => :search, :action => :enterprises, :facet => {:solr_plugin_f_profile_type => NetworksPlugin::Network.to_s}
  end

  protected

  extend HMVC::ClassMethods
  hmvc NetworksPlugin

end
