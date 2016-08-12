class ConsumersCoopPluginOrderController < OrdersCyclePluginOrderController

  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  protected

  extend HMVC::ClassMethods
  hmvc OrdersCyclePlugin

end
