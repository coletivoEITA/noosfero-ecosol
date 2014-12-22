class ConsumersCoopPluginSupplierController < OrdersCyclePluginSupplierController

  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  no_design_blocks

  protected

  extend ControllerInheritance::ClassMethods
  hmvc ConsumersCoopPlugin

end
