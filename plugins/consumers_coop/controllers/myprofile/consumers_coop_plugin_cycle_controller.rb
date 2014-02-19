class ConsumersCoopPluginCycleController < OrdersCyclePluginCycleController

  no_design_blocks
  include ConsumersCoopPlugin::TranslationHelper

  helper ConsumersCoopPlugin::TranslationHelper

  protected

  include ControllerInheritance
  replace_url_for self.superclass => self, OrdersPluginConsumerController => ConsumersCoopPluginOrderController

end
