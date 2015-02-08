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
    ['locale', 'toggle_edit', 'sortable-table', 'help', 'orders'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    [
      {
        :title => I18n.t("orders_plugin.lib.plugin.#{'person_' if profile.person?}panel_button"),
        :icon => 'orders-purchases-sales', :url => {:controller => :orders_plugin_admin, :action => :index},
      },
    ]
  end

end

# workaround for plugin class scope problem
require_dependency 'orders_plugin/display_helper'
OrdersPlugin::OrdersDisplayHelper = OrdersPlugin::DisplayHelper

