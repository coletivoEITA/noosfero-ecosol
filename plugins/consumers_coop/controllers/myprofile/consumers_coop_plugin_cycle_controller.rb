class ConsumersCoopPluginCycleController < OrdersCyclePluginCycleController

  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  protected

  extend HMVC::ClassMethods
  hmvc ConsumersCoopPlugin

end
