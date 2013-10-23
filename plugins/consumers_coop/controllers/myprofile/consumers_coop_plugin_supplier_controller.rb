class ConsumersCoopPluginSupplierController < OrdersCyclePluginSupplierController

  include ControllerInheritance
  include ConsumersCoopPlugin::TranslationHelper

  no_design_blocks

  protected

  replace_url_for self.superclass

end
