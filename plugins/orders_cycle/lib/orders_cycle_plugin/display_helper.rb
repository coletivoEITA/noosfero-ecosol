# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
require_dependency 'orders_plugin/date_helper'

module OrdersCyclePlugin::DisplayHelper

  protected

  include ::ActionView::Helpers::JavaScriptHelper # we want the original button_to_function!
  include OrdersPlugin::PriceHelper
  include OrdersPlugin::DisplayHelper
  include OrdersPlugin::DateHelper
  include SuppliersPlugin::SuppliersDisplayHelper

  def excerpt_ending text, length
    return nil if text.blank?
    excerpt text, text.first(3), length
  end

end
