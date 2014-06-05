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
    ['loading-overlay', 'locale', 'toggle_edit', 'sortable-table', 'stock'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    profile = context.profile
    return unless profile.identifier == 'maceladourada'
    [
      {:title => I18n.t('stock_plugin.views.control_panel.suppliers'), :icon => 'stock-manage', :url => {:controller => :stock_plugin_myprofile, :action => :index}},
    ]
  end

end

# workaround for plugins' scope problem
require_dependency 'stock_plugin/display_helper'
StockPlugin::StockDisplayHelper = StockPlugin::DisplayHelper
