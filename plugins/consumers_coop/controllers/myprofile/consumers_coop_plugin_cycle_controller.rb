class ConsumersCoopPluginCycleController < OrdersCyclePluginCycleController

  no_design_blocks
  include ControllerInheritance
  replace_url_for self.superclass
  include ConsumersCoopPlugin::TranslationHelper

  protected

end
