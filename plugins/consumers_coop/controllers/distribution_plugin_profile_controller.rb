# workaround for plugin class scope problem
require_dependency 'consumers_coop_plugin/display_helper'

class ConsumersCoopPluginProfileController < ProfileController

  include ConsumersCoopPlugin::ControllerHelper

  helper ApplicationHelper
  helper ConsumersCoopPlugin::DisplayHelper

  protected

end
