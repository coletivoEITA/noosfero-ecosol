# workaround for plugin class scope problem
require 'orders_plugin/display_helper'
require 'orders_plugin/date_helper'
require 'suppliers_plugin/display_helper'

module OrdersCyclePlugin::DisplayHelper

  protected

  include ::ActionView::Helpers::JavaScriptHelper # we want the original button_to_function!
  include OrdersPlugin::DisplayHelper
  include SuppliersPlugin::DisplayHelper

end
