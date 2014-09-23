require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/product"

class StockPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('stock_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('stock_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['locale', 'toggle_edit', 'sortable-table', 'stock'].map{ |j| "javascripts/#{j}" }
  end

  def product_tabs product
    user = context.send :user
    profile = context.profile
    return unless profile.identifier == 'maceladourada'
    return unless user and user.has_permission? 'manage_products', profile
    return if profile.stock_places.empty?
    {
      :title => I18n.t('stock_plugin.lib.plugin.manage_products.stock_tab'), :id => 'product-stock',
      :content => lambda{ render 'stock_plugin_manage_products/stock_tab', :product => product }
    }
  end

  def control_panel_buttons
    profile = context.profile
    return unless profile.identifier == 'maceladourada'
    [
      {:title => I18n.t('stock_plugin.views.control_panel.manage'), :icon => 'stock-manage', :url => {:controller => :stock_plugin_myprofile, :action => :index}},
    ]
  end

end

# workaround for plugins' scope problem
require_dependency 'stock_plugin/display_helper'
StockPlugin::StockDisplayHelper = StockPlugin::DisplayHelper
