require_dependency "#{File.dirname __FILE__}/ext/profile"
# extensions continue in the end

class OrdersPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('orders_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('orders_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['loading-overlay', 'locale', 'toggle_edit', 'sortable-table', 'help', 'orders'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    [
      { :title => I18n.t('orders_plugin.lib.plugin.panel_button'), :icon => 'orders-purchases-sales', :url => {:controller => :orders_plugin_admin, :action => :index} },
    ]
  end

end

# these need OrdersPlugin class defined
require_dependency "#{File.dirname __FILE__}/ext/product"

# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

