class ConsumersCoopPluginCycleController < OrdersCyclePluginCycleController

  no_design_blocks
  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  protected

  extend ControllerInheritance::ClassMethods
  hmvc ConsumersCoopPlugin

end
