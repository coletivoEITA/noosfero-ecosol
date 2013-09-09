# workaround for plugin class scope problem
require_dependency 'consumers_coop_plugin/display_helper'

class ConsumersCoopPluginMyprofileController < MyProfileController

  include ConsumersCoopPlugin::ControllerHelper

  helper ApplicationHelper
  helper ConsumersCoopPlugin::DisplayHelper

  protected

end
