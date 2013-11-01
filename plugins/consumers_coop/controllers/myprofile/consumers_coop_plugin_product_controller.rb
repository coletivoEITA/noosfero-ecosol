class ConsumersCoopPluginProductController < OrdersCyclePluginProductController

  no_design_blocks
  include ControllerInheritance
  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  protected

  replace_url_for self.superclass

end
