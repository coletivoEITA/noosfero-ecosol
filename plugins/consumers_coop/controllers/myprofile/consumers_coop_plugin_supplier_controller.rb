class ConsumersCoopPluginSupplierController < OrdersCyclePluginSupplierController

  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  no_design_blocks

  protected

  include ControllerInheritance
  replace_url_for self.superclass => self

end
