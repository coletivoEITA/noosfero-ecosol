require_dependency "#{File.dirname __FILE__}/ext/profile"

require_dependency "#{File.dirname __FILE__}/ext/delivery_plugin/option"

require_dependency "#{File.dirname __FILE__}/ext/suppliers_plugin/base_product"

class OrdersCyclePlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('orders_cycle_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('orders_cycle_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['orders_cycle'].map{ |j| "javascripts/#{j}" }
  end

end

# workaround for plugin class scope problem
require_dependency 'orders_cycle_plugin/display_helper'
OrdersCyclePlugin::OrdersCycleDisplayHelper = OrdersCyclePlugin::DisplayHelper

