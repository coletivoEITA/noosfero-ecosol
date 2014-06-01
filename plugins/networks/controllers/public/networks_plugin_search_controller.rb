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

  extend ControllerInheritance::ClassMethods
  hmvc NetworksPlugin

end
