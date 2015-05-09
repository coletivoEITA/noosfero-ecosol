class ConsumersCoopPluginSupplierController < OrdersCyclePluginSupplierController

  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  no_design_blocks

  protected

  extend HMVC::ClassMethods
  hmvc ConsumersCoopPlugin

end
