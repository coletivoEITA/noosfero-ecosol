class OrdersPluginController < PublicController

  include OrdersPlugin::TranslationHelper

  no_design_blocks

  helper OrdersPlugin::TranslationHelper
  helper OrdersPlugin::OrdersDisplayHelper

  def repeat
  end

end

